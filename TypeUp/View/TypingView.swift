//
//  TypingView.swift
//  TypeUp
//
//  Created by Kennard M on 13/09/26.
//

import SwiftUI

struct TypingView: View {
    let words: [String]

    var body: some View {
        Text(words.joined(separator: " "))
            .font(.system(size: 18, design: .monospaced))
    }
}

#Preview {
    @Previewable @State var viewModel = TypingViewModel()
    TypingView(words: viewModel.words)
}

