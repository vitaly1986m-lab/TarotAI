import SwiftUI
import AuthenticationServices
import GoogleSignIn

class AuthManager: NSObject, ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn = false

    // MARK: - Apple Sign In

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = credential.user
                UserDefaults.standard.set(userId, forKey: "appleUserId")
                isLoggedIn = true
            }
        case .failure(let error):
            print("Apple Sign In failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Google Sign In

    func signInWithGoogle(presenting viewController: UIViewController) {
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [weak self] result, error in
            if let error = error {
                print("Google Sign In failed: \(error.localizedDescription)")
                return
            }
            guard result?.user != nil else { return }
            DispatchQueue.main.async {
                self?.isLoggedIn = true
            }
        }
    }
}
