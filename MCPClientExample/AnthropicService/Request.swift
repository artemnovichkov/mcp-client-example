//
//  Created by Artem Novichkov on 09.05.2025.
//

import Foundation

struct Request: Encodable {
    let model: String
    let messages: [Message]
    let max_tokens: Int
    let tools: [Tool]?


    struct Message: Encodable {
        enum Role: String, Encodable {
            case user
            case assistant
        }
        
        let role: Role
        let content: [Content]
    }
}
