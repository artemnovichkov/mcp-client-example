//
//  Created by Artem Novichkov on 09.05.2025.
//

import SwiftUI
import Observation

@Observable
final class ContentViewModel {
    var messages: [ChatMessage] = []
    var inputText: String = "Check my last blood pressure and suggest recommendations"
    var isLoading: Bool = false

    private let mcpServerService: MCPServerProtocol
    private let anthropicService: AnthropicService

    init() {
        self.mcpServerService = BloodPressureService()
        self.anthropicService = AnthropicService(
            apiKey: "YOUR_API_KEY",
            tools: mcpServerService.tools
        )
    }

    func sendMessage() {
        let requestMessage = Request.Message(role: .user, content: [.text(text: inputText)])
        messages.append(.init(message: requestMessage))
        inputText = ""
        isLoading = true

        let requestMessages = messages.map(\.message)

        Task {
            do {
                let response = try await anthropicService.send(messages: requestMessages)
                let message = ChatMessage(message: .init(role: .assistant, content: response.content))
                self.messages.append(message)

                for content in response.content {
                    switch content {
                    case .toolUse(let id, let name, _):
                        try await useTool(withID: id, name: name)
                    case .text, .toolResult:
                        continue
                    }
                }
            } catch {
                print("Error: \(error)")
            }
            self.isLoading = false
        }
    }

    // MARK: - Private

    private func useTool(withID id: String, name: String) async throws {
        // 1. Find the tool by name
        guard let tool = mcpServerService.tools.first(where: { $0.name == name }) else {
            print("Tool with name \(name) not found.")
            return
        }
        // 2. Create the tool result content
        let content = try await mcpServerService.call(tool)
        let toolResultMessage = Request.Message(
            role: .user,
            content: [.toolResult(toolUseId: id, content: content)]
        )

        self.messages.append(.init(message: toolResultMessage))

        // 3. Send the tool result message
        let requestMessages = self.messages.map(\.message)
        let response = try await anthropicService.send(messages: requestMessages)
        let message = ChatMessage(message: .init(role: .assistant, content: response.content))
        self.messages.append(message)
    }
}

struct ChatMessage: Identifiable {

    let message: Request.Message

    var id: UUID = .init()

    var content: String {
        message.content
            .map { content in
                switch content {
                case .text(let text):
                    text
                case .toolUse(_, let name, _):
                    "Called MCP Tool: \(name)"
                case .toolResult(_, let content):
                    "Result: \(content)"
                }
            }
            .joined(separator: "\n")
    }
}
