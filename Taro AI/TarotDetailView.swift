import SwiftUI

struct TarotDetailView: View {
    let image: UIImage
    let detectedCards: [TarotCard]
    
    @State private var analysisText = "Анализируем расклад…"
        @State private var isLoading = true

        private let visionService = ChatGPTVisionService()

    struct TarotCard: Identifiable {
        let id = UUID()
        let name: String
        let description: String
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Фото расклада
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .shadow(radius: 8)
                    .padding()
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(analysisText)
                        .foregroundColor(.white)
                        .padding()
                }


                // Заголовок
                Text("Обнаруженные карты")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

                // Список карт с описанием
                ForEach(detectedCards) { card in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.name)
                            .font(.headline)
                            .foregroundColor(.yellow)

                        Text(card.description)
                            .foregroundColor(.white.opacity(0.85))
                            .font(.subheadline)
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(12)
                }
                
                .onAppear {
                        visionService.analyzeTarot(image: image) { result in
                            DispatchQueue.main.async {
                                isLoading = false
                                switch result {
                                case .success(let text):
                                    analysisText = text
                                case .failure:
                                    analysisText = "Не удалось проанализировать расклад."
                                }
                            }
                        }
                    }

                Spacer()
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.02, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
        )
    }
}

