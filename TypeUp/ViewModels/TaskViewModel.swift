//
//  TaskViewModel.swift
//  TypeUp
//
//  Created by Kennard M on 09/09/26.
//

import SwiftUI
import Foundation
@Observable class TaskViewModel {
    var tasks: [Task] = [
        Task(title: "Clean the House", isDone: false),
        Task(title: "Sweep floor", isDone: true),
        Task(title: "Eat", isDone: false),
    ]
    
    func toggleTask(_tasks: Task){
        guard let index = tasks.firstIndex(where: { $0.id == _tasks.id})
        else {return}
        tasks[index].isDone.toggle()
    }
}
