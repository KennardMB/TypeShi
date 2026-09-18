//
//  FinishedView.swift
//  TypeUp
//
//  Created by Kennard M on 16/09/26.
//

import SwiftUI

struct FinishedView: View {
    var viewModel: TypingViewModel
    
    
    var body: some View {
        VStack{
            Text("\(viewModel.wpm) WPM")
            Text("\(viewModel.correctWordCount) Correct Words")
            
            VStack(spacing: 2){
                Button("Restart (tab)") {
                    viewModel.restart()
                }
                Button("Quit (esc)") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .font(.system(size: 13, design: .monospaced))
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    @Previewable @State var viewModel = TypingViewModel()
    FinishedView(viewModel: viewModel)
}
