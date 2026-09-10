//
//  TypeUpApp.swift
//  TypeUp
//
//  Created by Kennard M on 08/09/26.
//

import SwiftUI

@main 
struct TypeUpApp: App {
    var body: some Scene {
        //        WindowGroup {
        //            ContentView()
        //        }
        MenuBarExtra("TypeUp", systemImage: "keyboard.fill") {
            MenuBarContentView()            
        }
        .menuBarExtraStyle(.window)
        
    }
}
