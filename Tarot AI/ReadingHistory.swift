import Foundation
import FirebaseAuth
import FirebaseFirestore

struct TarotReading: Codable, Identifiable {
    @DocumentID var id: String?
    let date: Date
    let question: String
    let cardsFound: String
    let interpretation: String

    init(date: Date = Date(), question: String, cardsFound: String, interpretation: String) {
        self.date = date
        self.question = question
        self.cardsFound = cardsFound
        self.interpretation = interpretation
    }
}

class ReadingHistoryManager: ObservableObject {
    static let shared = ReadingHistoryManager()

    @Published var readings: [TarotReading] = []

    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()

    private var readingsCollection: CollectionReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(uid).collection("readings")
    }

    init() {}

    func startListening() {
        stopListening()

        guard let collection = readingsCollection else { return }

        listener = collection
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Firestore listen error: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                DispatchQueue.main.async {
                    self?.readings = documents.compactMap { doc in
                        try? doc.data(as: TarotReading.self)
                    }
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        DispatchQueue.main.async {
            self.readings = []
        }
    }

    func add(_ reading: TarotReading) {
        guard let collection = readingsCollection else { return }
        do {
            try collection.addDocument(from: reading)
        } catch {
            print("Error adding reading: \(error.localizedDescription)")
        }
    }

    func delete(at offsets: IndexSet) {
        guard let collection = readingsCollection else { return }
        for index in offsets {
            guard index < readings.count, let docId = readings[index].id else { continue }
            collection.document(docId).delete()
        }
    }

    func deleteReading(_ reading: TarotReading) {
        guard let collection = readingsCollection, let docId = reading.id else { return }
        collection.document(docId).delete()
    }
}
