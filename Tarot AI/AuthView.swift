import SwiftUI
import GoogleSignIn

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        if authManager.isLoggedIn {
            MainView()
                .environmentObject(authManager)
        } else {
            ZStack {
                LinearGradient(
                    colors: [.black, Color(red: 0.2, green: 0.0, blue: 0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }

                ScrollView {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 60)

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

                        // Email & Password fields
                        VStack(spacing: 12) {
                            TextField("Email", text: $authManager.email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(14)
                                .foregroundColor(.white)

                            SecureField("Пароль", text: $authManager.password)
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(14)
                                .foregroundColor(.white)

                            if !authManager.errorMessage.isEmpty {
                                Text(authManager.errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }

                            Button {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                authManager.signInWithEmail()
                            } label: {
                                Text(authManager.isRegistering ? "Зарегистрироваться" : "Войти")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        LinearGradient(
                                            colors: [.pink, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(26)
                            }

                            Button {
                                authManager.isRegistering.toggle()
                                authManager.errorMessage = ""
                            } label: {
                                Text(authManager.isRegistering ? "Уже есть аккаунт? Войти" : "Нет аккаунта? Зарегистрироваться")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.footnote)
                            }
                        }
                        .padding(.horizontal, 32)

                        // Divider
                        HStack {
                            Rectangle().frame(height: 0.5).foregroundColor(.white.opacity(0.3))
                            Text("или").foregroundColor(.white.opacity(0.5)).font(.footnote)
                            Rectangle().frame(height: 0.5).foregroundColor(.white.opacity(0.3))
                        }
                        .padding(.horizontal, 32)

                        // Google Sign In
                        Button {
                            guard let rootVC = UIApplication.shared.connectedScenes
                                .compactMap({ $0 as? UIWindowScene })
                                .first?.windows.first?.rootViewController else { return }
                            authManager.signInWithGoogle(presenting: rootVC)
                        } label: {
                            HStack(spacing: 10) {
                                Image("google_logo")
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
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

                        Spacer().frame(height: 40)
                    }
                }
                .scrollDismissesKeyboard(.interactively)

                if authManager.isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
            .disabled(authManager.isLoading)
        }
    }
}

#Preview {
    MainView()
}
