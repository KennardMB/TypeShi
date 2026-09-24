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
        MenuBarExtra("TypeUp", systemImage: "keyboard.fill") {
            MainMenuView()
                .frame(width: 500)
        }
        .menuBarExtraStyle(.window)
        
    }
}
