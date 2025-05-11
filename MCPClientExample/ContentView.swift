//
//  Created by Artem Novichkov on 09.05.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 8) {
                ForEach(viewModel.messages) { message in
                    let isUser = message.message.role == .user
                    VStack {
                        Text(message.content)
                            .padding(8)
                            .background(isUser ? Color.blue.opacity(0.2) : nil)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                TextField("Type a message...", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isLoading)
                Button("Send") {
                    viewModel.sendMessage()
                }
                .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
            }
            .padding()
            .background(.white)
        }
    }
}

#Preview {
    ContentView()
}
