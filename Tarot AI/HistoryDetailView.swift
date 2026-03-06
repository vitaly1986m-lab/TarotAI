import SwiftUI

struct HistoryDetailView: View {
    let reading: TarotReading

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Вопрос")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(reading.question)
                        .font(.title3)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Карты")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(reading.cardsFound)
                        .font(.body)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Трактовка")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(reading.interpretation)
                        .font(.body)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Дата")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(reading.date, format: .dateTime.day().month().year().hour().minute())
                        .font(.body)
                        .foregroundColor(.white)
                }
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
        .navigationTitle("Расклад")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
