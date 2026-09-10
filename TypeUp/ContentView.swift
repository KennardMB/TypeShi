//
//  ContentView.swift
//  TypeUp
//
//  Created by Kennard M on 08/09/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = TaskViewModel()
    
    var body: some View {
        NavigationView{
            List{
                ForEach(viewModel.tasks) { task in
                    HStack{
                        Text(task.title)
                        Spacer()
                        Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                            .onTapGesture {
                                viewModel.toggleTask(_tasks: task)
                            }
                    }
                }
            }
            .navigationTitle("Tasks")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
