import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.02, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            List {
                NavigationLink(destination: ProfileView()) {
                    Label("Профиль", systemImage: "person.circle")
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.white.opacity(0.08))

                NavigationLink(destination: HistoryView()) {
                    Label("История раскладов", systemImage: "clock.arrow.circlepath")
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.white.opacity(0.08))

                NavigationLink(destination: AppSettingsView()) {
                    Label("Настройки", systemImage: "gearshape")
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.white.opacity(0.08))
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
