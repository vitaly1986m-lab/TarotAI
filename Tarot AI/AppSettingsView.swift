import SwiftUI

struct AppSettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.02, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            List {
                Section("Уведомления") {
                    Toggle("Включить уведомления", isOn: $notificationsEnabled)
                        .tint(.purple)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.white.opacity(0.08))

                Section("Банковские карты") {
                    Text("Карты не привязаны")
                        .foregroundColor(.gray)
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
