import SwiftUI
import AuthenticationServices
import GoogleSignIn

struct AuthView: View {
    @StateObject private var authManager = AuthManager()

    var body: some View {
        if authManager.isLoggedIn {
            MainView()
        } else {
            ZStack {
                LinearGradient(
                    colors: [.black, Color(red: 0.2, green: 0.0, blue: 0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    Text("Tarot")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    +
                    Text(" ai")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Image("splash_image")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)

                    Spacer()

                    // Apple Sign In
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        authManager.handleAppleSignIn(result: result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 56)
                    .cornerRadius(28)
                    .padding(.horizontal, 32)

                    // Google Sign In
                    Button {
                        guard let rootVC = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .first?.windows.first?.rootViewController else { return }
                        authManager.signInWithGoogle(presenting: rootVC)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "g.circle.fill")
                                .font(.title2)
                            Text("Sign in with Google")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                        .frame(height: 60)
                }
            }
        }
    }
}

