import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.02, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                if let photoURL = authManager.currentUser?.photoURL {
                    AsyncImage(url: photoURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.purple)
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.purple)
                }

                VStack(spacing: 8) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(authManager.currentUser?.email ?? "Не указан")
                        .font(.title3)
                        .foregroundColor(.white)
                }

                Spacer()

                Button {
                    authManager.signOut()
                } label: {
                    Text("Выйти")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
            .padding(.top, 40)
        }
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
