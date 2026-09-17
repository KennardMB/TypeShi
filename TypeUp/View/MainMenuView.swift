//
//  MainMenuView.swift
//  TypeUp
//
//  Created by Kennard M on 09/09/26.
//

import SwiftUI

struct MainMenuView: View {
    
    @State private var viewModel = TypingViewModel()
    @FocusState private var isTypingFocused: Bool
    
    
    
    var body: some View {
        NavigationStack{
            VStack (alignment: .leading){
                HStack (){
                    // If timer is NOT ON
                    if viewModel.startDate == nil {
                        Button{
                            viewModel.cycleDuration()
                        } label: {
                            Text("\(viewModel.selectedDuration.rawValue)")
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        // If timer is ON
                        TimelineView(.periodic(from: viewModel.startDate ?? .now, by: 1)){ context in
                            Button {
                                viewModel.cycleDuration()
                            } label: {
                                Text("\(viewModel.remainingSeconds(at: context.date))")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    NavigationLink (destination: ContentView()){
                        Image(systemName: "gearshape.fill")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink (destination: ContentView()){
                        Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .font(.system(size: 18, design: .monospaced))
                
                //words view
                TypingView(viewModel: viewModel)
                    .focusable()
                    .focusEffectDisabled()
                    .focused($isTypingFocused)
                    .onKeyPress { press in
                        print("key:", press.key, "chars:", String(describing: press.characters))
                        
                        switch press.key {
                        case .delete, KeyEquivalent("\u{7F}"):
                            viewModel.handleBackspace()
                        case .space:
                            viewModel.commitWord()
                        default:
                            viewModel.handleTypedCharacters(press.characters)
                        }
                        return .handled
                    }
                    .onAppear {
                        isTypingFocused = true
                    }
                
                //DEBUG TYPED BUFFER
                Text("\(viewModel.currentIndex) |\(viewModel.typedBuffer)|")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.secondary)
                
                
                
                VStack (spacing: 2){
                    Button("Restart (tab)"){
                        viewModel.restart()
                    }
                    
                    Button("Quit (esc)"){
                        NSApplication.shared.terminate(nil)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
}

#Preview {
    MainMenuView()
}
