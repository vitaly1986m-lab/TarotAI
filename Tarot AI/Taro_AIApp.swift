import SwiftUI
import GoogleSignIn

@main
struct TarotAIApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}


