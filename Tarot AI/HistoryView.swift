import SwiftUI

struct HistoryView: View {
    @ObservedObject private var historyManager = ReadingHistoryManager.shared

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.02, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if historyManager.readings.isEmpty {
                Text("Пока нет раскладов")
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(historyManager.readings) { reading in
                        NavigationLink(destination: HistoryDetailView(reading: reading)) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(reading.question)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Text(reading.cardsFound)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                Text(reading.date, style: .date)
                                    .font(.caption2)
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.white.opacity(0.08))
                    }
                    .onDelete { offsets in
                        historyManager.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("История")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
