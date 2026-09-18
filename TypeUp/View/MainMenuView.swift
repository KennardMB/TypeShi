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
                //timer, setting, history
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
                .font(.system(size: 13, design: .monospaced))
                
                //words view
                
                //older code
//                if viewModel.startDate == nil {
//                    TypingView(viewModel: viewModel)
//                        .focusable()
//                        .focusEffectDisabled()
//                        .focused($isTypingFocused)
//                        .onKeyPress { press in
//                            print("key:", press.key, "chars:", String(describing: press.characters))
//                            switch press.key {
//                            case .delete, KeyEquivalent("\u{7F}"):
//                                viewModel.handleBackspace()
//                            case .space:
//                                viewModel.commitWord()
//                            default:
//                                viewModel.handleTypedCharacters(press.characters)
//                            }
//                            return .handled
//                        }
//                        .onAppear {
//                            isTypingFocused = true
//                        }
//                }
                
                // newer code
                TimelineView(.periodic(from: viewModel.startDate ?? .now, by: 1)) { context in
                    if viewModel.isFinished(at: context.date) {
                        FinishedView(viewModel: viewModel)
                            .focusable()
                            .focusEffectDisabled()
                            .focused($isTypingFocused)
                            .onKeyPress(.tab) {
                                viewModel.restart()
                                return .handled
                            }
                            .onAppear { isTypingFocused = true }
                    } else {
                        TypingView(viewModel: viewModel)
                            .focusable()
                            .focusEffectDisabled()
                            .focused($isTypingFocused)
                            .onKeyPress { press in
                                switch press.key {
                                case .tab:
                                    viewModel.restart()
                                case .delete, KeyEquivalent("\u{7F}"):
                                    viewModel.handleBackspace()
                                case .space:
                                    viewModel.commitWord()
                                case .tab:
                                        viewModel.restart()
                                default:
                                    viewModel.handleTypedCharacters(press.characters)
                                }
                                return .handled
                            }
                            .onAppear { isTypingFocused = true }
                    }
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
                .font(.system(size: 11))
                .frame(maxWidth: .infinity)
            }
            .padding()
            .onKeyPress(.tab) {
                viewModel.restart()
                return .handled
            }
            .onKeyPress(.escape) {
                NSApplication.shared.terminate(nil)
                return .handled
            }

        }
    }
}

#Preview {
    MainMenuView()
}
