//
//  TypingView.swift
//  TypeUp
//
//  Created by Kennard M on 13/09/26.
//

import SwiftUI

struct TypingView: View {
    var viewModel: TypingViewModel
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8){
            if viewModel.currentIndex < viewModel.words.count {
                currentWord(viewModel.words[viewModel.currentIndex])
                
                let rest = viewModel.words[(viewModel.currentIndex + 1)...]
                Text(rest.joined(separator: " "))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .font(.system(size: 16, design: .monospaced))
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }
    
    @ViewBuilder
    private func currentWord(_ word: String) -> some View {
        let target = Array(word)
        let buffer = Array (viewModel.typedBuffer)
        
        HStack(spacing:0){
            //correct, incorrect, and untyped display
            ForEach(0..<target.count, id: \.self) { letterIndex in
                let state = viewModel.letterState(at: letterIndex)
                let display = String(target[letterIndex])
                Text(display)
                    .foregroundStyle(color(for: state))
            }
            //Extraincorrect display
            if buffer.count > target.count {
                ForEach(target.count..<buffer.count, id: \.self) { letterIndex in
                Text(String(buffer[letterIndex]))
                        .foregroundStyle(.red)
                }
            }
        }
    }
    
    private func color(for state: TypingViewModel.LetterState) -> Color {
        switch state {
        case .untyped: return .secondary
        case .correct: return .green
        case .incorrect, .extraIncorrect: return .red
        }
    }
    
}

#Preview {
    @Previewable @State var viewModel = TypingViewModel()
    TypingView(viewModel: viewModel)
}

