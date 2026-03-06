import Foundation
import FirebaseAuth
import FirebaseFirestore

struct MigrationManager {

    private struct LocalTarotReading: Codable {
        let id: UUID
        let date: Date
        let question: String
        let cardsFound: String
        let interpretation: String
    }

    static func migrateIfNeeded() {
        let migrationKey = "hasCompletedFirestoreMigration"
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }

        guard let data = UserDefaults.standard.data(forKey: "tarot_readings"),
              let localReadings = try? JSONDecoder().decode([LocalTarotReading].self, from: data),
              !localReadings.isEmpty else {
            UserDefaults.standard.set(true, forKey: migrationKey)
            return
        }

        let db = Firestore.firestore()
        let collection = db.collection("users").document(uid).collection("readings")
        let batch = db.batch()

        for reading in localReadings {
            let docRef = collection.document()
            let firestoreReading = TarotReading(
                date: reading.date,
                question: reading.question,
                cardsFound: reading.cardsFound,
                interpretation: reading.interpretation
            )
            if let encoded = try? Firestore.Encoder().encode(firestoreReading) {
                batch.setData(encoded, forDocument: docRef)
            }
        }

        batch.commit { error in
            if let error = error {
                print("Migration error: \(error.localizedDescription)")
            } else {
                UserDefaults.standard.set(true, forKey: migrationKey)
                print("Migration completed: \(localReadings.count) readings migrated")
            }
        }
    }
}
