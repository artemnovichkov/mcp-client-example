//
//  Created by Artem Novichkov on 09.05.2025.
//

enum Content: Codable {
    case text(text: String)
    /// Modern models think by default and return these blocks before the answer.
    /// `signature` is an opaque, encrypted copy of the reasoning: it must be sent back
    /// unchanged with the rest of the assistant turn, otherwise the reasoning is lost.
    /// Based on [docs](https://platform.claude.com/docs/en/build-with-claude/thinking)
    case thinking(thinking: String, signature: String)
    /// Same round-trip rules as `thinking`, but the reasoning is safety-redacted.
    case redactedThinking(data: String)
    case toolUse(id: String, name: String, input: [String: String])
    case toolResult(toolUseId: String, content: String)

    private enum CodingKeys: String, CodingKey {
        case type, text, thinking, signature, data, id, name, input, tool_use_id, content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text":
            let text = try container.decode(String.self, forKey: .text)
            self = .text(text: text)
        case "thinking":
            let thinking = try container.decode(String.self, forKey: .thinking)
            let signature = try container.decode(String.self, forKey: .signature)
            self = .thinking(thinking: thinking, signature: signature)
        case "redacted_thinking":
            let data = try container.decode(String.self, forKey: .data)
            self = .redactedThinking(data: data)
        case "tool_use":
            let id = try container.decode(String.self, forKey: .id)
            let name = try container.decode(String.self, forKey: .name)
            let input = try container.decode([String: String].self, forKey: .input)
            self = .toolUse(id: id, name: name, input: input)
        case "tool_result":
            let toolUseId = try container.decode(String.self, forKey: .tool_use_id)
            let content = try container.decode(String.self, forKey: .content)
            self = .toolResult(toolUseId: toolUseId, content: content)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown content type: \(type)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .thinking(let thinking, let signature):
            try container.encode("thinking", forKey: .type)
            try container.encode(thinking, forKey: .thinking)
            try container.encode(signature, forKey: .signature)
        case .redactedThinking(let data):
            try container.encode("redacted_thinking", forKey: .type)
            try container.encode(data, forKey: .data)
        case .toolUse(let id, let name, let input):
            try container.encode("tool_use", forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(input, forKey: .input)
        case .toolResult(let toolUseId, let content):
            try container.encode("tool_result", forKey: .type)
            try container.encode(toolUseId, forKey: .tool_use_id)
            try container.encode(content, forKey: .content)
        }
    }
}
