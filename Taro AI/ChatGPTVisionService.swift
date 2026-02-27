import Foundation
import UIKit

final class ChatGPTVisionService {

    private let apiKey = "pza_IusfiNeLAOHaiaMk3EJB8F3UnYwFd9Nc"
    private let endpoint = URL(string: "https://api.polza.ai/v1/chat/completions")!
    
    func analyzeTarot(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {

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
            "input": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "input_text",
                            "text": prompt
                        ],
                        [
                            "type": "input_image",
                            "image_base64": base64Image
                        ]
                    ]
                ]
            ],
            "max_output_tokens": 600
        ]
    

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer YOUR_POLZA_API_KEY", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print("📩 RAW RESPONSE:")
                print(String(data: data, encoding: .utf8) ?? "nil")
            }

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
