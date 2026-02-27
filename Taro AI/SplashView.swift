import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            MainView()
        } else {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                Image("splash_image") // положи картинку в Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

