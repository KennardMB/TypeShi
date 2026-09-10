//
//  MainMenuView.swift
//  TypeUp
//
//  Created by Kennard M on 09/09/26.
//

import SwiftUI

struct MainMenuView: View {
    
    @State private var viewModel = TypingViewModel()
    
    
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
                
                Text("this they are how why turn many late of then play")
                    .font(.system(size: 20, design: .monospaced))
                
                
                VStack (spacing: 2){
                    Button("Begin Countdown (debug)"){
                        viewModel.beginCountdown()
                    }

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
