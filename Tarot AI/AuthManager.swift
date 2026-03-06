import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: FirebaseAuth.User?
    @Published var email = ""
    @Published var password = ""
    @Published var isRegistering = false
    @Published var errorMessage = ""
    @Published var isLoading = false

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isLoggedIn = user != nil
                if user != nil {
                    ReadingHistoryManager.shared.startListening()
                    MigrationManager.migrateIfNeeded()
                } else {
                    ReadingHistoryManager.shared.stopListening()
                }
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Email Sign In / Register

    func signInWithEmail() {
        guard isValidEmail(email) else {
            errorMessage = "Введите корректный email"
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Пароль должен быть не менее 6 символов"
            return
        }
        errorMessage = ""
        isLoading = true

        if isRegistering {
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] _, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = self?.mapFirebaseError(error) ?? error.localizedDescription
                    }
                }
            }
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = self?.mapFirebaseError(error) ?? error.localizedDescription
                    }
                }
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    // MARK: - Google Sign In

    func signInWithGoogle(presenting viewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Ошибка конфигурации: CLIENT_ID не найден в GoogleService-Info.plist"
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        isLoading = true

        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else { return }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { [weak self] _, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = self?.mapFirebaseError(error) ?? error.localizedDescription
                    }
                }
            }
        }
    }

    // MARK: - Sign Out

    func signOut() {
        ReadingHistoryManager.shared.stopListening()
        GIDSignIn.sharedInstance.signOut()
        try? Auth.auth().signOut()
    }

    // MARK: - Error Mapping

    private func mapFirebaseError(_ error: Error) -> String {
        let code = (error as NSError).code
        switch code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Этот email уже зарегистрирован"
        case AuthErrorCode.wrongPassword.rawValue:
            return "Неверный пароль"
        case AuthErrorCode.userNotFound.rawValue:
            return "Пользователь не найден"
        case AuthErrorCode.invalidEmail.rawValue:
            return "Некорректный email"
        case AuthErrorCode.weakPassword.rawValue:
            return "Пароль слишком слабый"
        case AuthErrorCode.networkError.rawValue:
            return "Ошибка сети. Проверьте подключение"
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Слишком много попыток. Попробуйте позже"
        default:
            return error.localizedDescription
        }
    }
}
