//
//  TypingView.swift
//  TypeUp
//
//  Created by Kennard M on 13/09/26.
//

import SwiftUI

private struct TypingCenterAlignment: AlignmentID {
    static func defaultValue(in dimensions: ViewDimensions) -> CGFloat {
        dimensions[HorizontalAlignment.center]
    }
}

extension HorizontalAlignment {
    fileprivate static let typingCenter = HorizontalAlignment(TypingCenterAlignment.self)
}

struct TypingView: View {
    var viewModel: TypingViewModel

    var body: some View {
        // The slot takes a normal width. The word line is only an overlay,
        // so its full length cannot widen the popover and push the timer row away.
        Color.clear
            .frame(height: 26)
            .frame(maxWidth: .infinity)
            .overlay(alignment: Alignment(horizontal: .typingCenter, vertical: .center)) {
                wordLine
            }
            .clipped()
    }

    private var wordLine: some View {
        HStack(alignment: .center, spacing: 8) {
            ForEach(0..<viewModel.currentIndex, id: \.self) { index in
                pastWord(
                    viewModel.words[index],
                    typed: viewModel.committedTyped(at: index)
                )
            }

            if viewModel.currentIndex < viewModel.words.count {
                currentWord(viewModel.words[viewModel.currentIndex])
                    .alignmentGuide(HorizontalAlignment.typingCenter) { dimensions in
                        dimensions[HorizontalAlignment.center]
                    }

                ForEach((viewModel.currentIndex + 1)..<viewModel.words.count, id: \.self) { index in
                    Text(viewModel.words[index])
                        .foregroundStyle(.secondary)
                }
            } else {
                caret
                    .alignmentGuide(HorizontalAlignment.typingCenter) { dimensions in
                        dimensions[HorizontalAlignment.center]
                    }
            }
        }
        .font(.system(size: 16, design: .monospaced))
        .fixedSize(horizontal: true, vertical: true)
    }

    private func currentWord(_ word: String) -> some View {
        let buffer = Array(viewModel.typedBuffer)
        return lineText(target: Array(word), buffer: buffer, live: true)
            .overlay(alignment: .leading) {
                // Hidden prefix has the same width as the typed letters.
                // The caret draws on top and does not push the word apart.
                HStack(spacing: 0) {
                    Text(String(buffer))
                        .hidden()
                    caret
                }
                .fixedSize()
            }
    }

    private func pastWord(_ word: String, typed: String) -> Text {
        lineText(target: Array(word), buffer: Array(typed), live: false)
    }

    private func lineText(target: [Character], buffer: [Character], live: Bool) -> Text {
        let glyphCount = max(target.count, buffer.count)
        var line = Text("")
        for index in 0..<glyphCount {
            if index < target.count {
                let state = live
                    ? viewModel.letterState(at: index)
                    : pastState(target: target, buffer: buffer, index: index)
                line = line + Text(String(target[index])).foregroundStyle(color(for: state))
            } else if index < buffer.count {
                line = line + Text(String(buffer[index])).foregroundStyle(.red)
            }
        }
        return line
    }

    private func pastState(target: [Character], buffer: [Character], index: Int) -> TypingViewModel.LetterState {
        guard index < buffer.count else { return .incorrect }
        return buffer[index] == target[index] ? .correct : .incorrect
    }

    private var caret: some View {
        TimelineView(.periodic(from: Date(timeIntervalSinceReferenceDate: 0), by: 0.53)) { context in
            let tick = Int(context.date.timeIntervalSinceReferenceDate / 0.53)
            Rectangle()
                .fill(Color.white)
                .frame(width: 2, height: 18)
                .opacity(tick.isMultiple(of: 2) ? 1 : 0)
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
        .frame(width: 500)
}
