import SwiftUI

struct TarotDetailView: View {
    let image: UIImage
    var question: String = ""

    @State private var analysisText = "Анализируем расклад…"
    @State private var isLoading = true

    private let visionService = ChatGPTVisionService.shared

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

                // Заголовок
                Text("Обнаруженные карты")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(analysisText)
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .padding()
            .onAppear {
                        visionService.analyzeTarot(image: image) { result in
                            DispatchQueue.main.async {
                                isLoading = false
                                switch result {
                                case .success(let text):
                                    analysisText = text
                                    let reading = TarotReading(
                                        question: question.isEmpty ? "Без вопроса" : question,
                                        cardsFound: String(text.prefix(100)),
                                        interpretation: text
                                    )
                                    ReadingHistoryManager.shared.add(reading)
                                case .failure:
                                    analysisText = "Не удалось проанализировать расклад."
                                }
                            }
                        }
                    }
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

