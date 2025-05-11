//
//  Created by Artem Novichkov on 09.05.2025.
//

import Foundation

final class AnthropicService {

    private let apiKey: String
    private let tools: [Tool]
    
    init(apiKey: String, tools: [Tool]) {
        self.apiKey = apiKey
        self.tools = tools
    }
    
    func send(messages: [Request.Message]) async throws -> Response {
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let body = Request(model: "claude-3-opus-20240229", messages: messages, max_tokens: 1024, tools: tools)
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try JSONDecoder().decode(Response.self, from: data)
    }
}
