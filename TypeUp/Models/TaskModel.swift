//
//  Model.swift
//  TypeUp
//
//  Created by Kennard M on 09/09/26.
//

import SwiftUI
import Foundation

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool
}
