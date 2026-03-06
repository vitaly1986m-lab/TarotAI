import Foundation
import UIKit
import FirebaseRemoteConfig

final class ChatGPTVisionService {

    static let shared = ChatGPTVisionService()

    private let endpoint = URL(string: "https://api.polza.ai/v1/chat/completions")!
    private let queue = DispatchQueue(label: "com.tarotai.visionservice")

    private var _apiKey = ""
    private var pendingCallbacks: [((String) -> Void)] = []
    private var isFetching = false

    private init() {
        fetchAPIKey(retryCount: 0)
    }

    private func fetchAPIKey(retryCount: Int) {
        queue.sync { isFetching = true }

        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        remoteConfig.fetchAndActivate { [self] status, error in
            let key = remoteConfig.configValue(forKey: "polza_api_key").stringValue
            if key.isEmpty && retryCount < 5 {
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    self.fetchAPIKey(retryCount: retryCount + 1)
                }
                return
            }

            queue.sync {
                self._apiKey = key
                self.isFetching = false
                let callbacks = self.pendingCallbacks
                self.pendingCallbacks = []
                for cb in callbacks {
                    cb(key)
                }
            }
        }
    }

    private func getAPIKey(completion: @escaping (String) -> Void) {
        queue.sync {
            if !_apiKey.isEmpty {
                completion(_apiKey)
            } else if isFetching {
                pendingCallbacks.append(completion)
            } else {
                completion("")
            }
        }
    }

    func analyzeTarot(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        getAPIKey { [self] key in
            guard !key.isEmpty else {
                completion(.failure(NSError(domain: "ConfigError", code: 0,
                                           userInfo: [NSLocalizedDescriptionKey: "API ключ не загружен. Проверьте Remote Config."])))
                return
            }
            self.performAnalysis(apiKey: key, image: image, completion: completion)
        }
    }

    private func performAnalysis(apiKey: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let base64Image = image.toBase64() else {
            completion(.failure(NSError(domain: "ImageError", code: 0)))
            return
        }

        let prompt = """
        You are a professional tarot reader.
        Analyze the tarot spread on the image.
        1. List all tarot cards you see.
        2. Explain the meaning of each card.
        Respond in Russian.
        """

        let body: [String: Any] = [
            "model": "gpt-4.1-mini",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": prompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 600
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let choices = json["choices"] as? [[String: Any]],
                let message = choices.first?["message"] as? [String: Any],
                let content = message["content"] as? String
            else {
                completion(.failure(NSError(domain: "ParseError", code: 0)))
                return
            }

            completion(.success(content))

        }.resume()
    }
}
