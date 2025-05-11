//
//  Created by Artem Novichkov on 09.05.2025.
//

import Foundation

protocol MCPServerProtocol {
    var tools: [Tool] { get }
    func call(_ tool: Tool) async throws -> String
} 

/// Based on [docs](https://modelcontextprotocol.io/docs/concepts/tools#tool-definition-structure)
struct Tool: Encodable {

    enum CodingKeys: String, CodingKey {
        case name, toolDescription = "description", input_schema
    }

    let name: String
    let toolDescription: String
    let input_schema: [String: String]
} 
