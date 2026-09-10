//
//  TimerViewModel.swift
//  TypeUp
//
//  Created by Kennard M on 10/09/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class TypingViewModel {
    enum Duration: Int, CaseIterable {
        case fifteen = 15
        case thirty = 30
        case sixty = 60
        
        var next: Duration {
            let all = Self.allCases
            let index = all.firstIndex(of:self)!
            // all.count = 3, so it would be 1/3 = 1, 2/3 = 2, 3/3 = 0
            return all[(index + 1) % all.count]
        }
    }
    
    var selectedDuration: Duration = .fifteen
    private(set) var startDate: Date?
    
    func remainingSeconds(at now: Date) -> Int {
        guard let startDate else {
            return selectedDuration.rawValue
        }
        let elapsed = now.timeIntervalSince(startDate) // returns a Double
        return max(0, selectedDuration.rawValue - Int(elapsed)) // max for date before now, Int(elapsed) changes from Double to Int
        // elapsed = (time since start of trigger)
        // remainingSeconds = (selected duration) - (time since start of trigger)
    }
    
    func cycleDuration() {
        guard startDate == nil else { return }
        selectedDuration = selectedDuration.next
    }
    
    func beginCountdown(at now: Date = .now){
        if startDate == nil {
            startDate = now
        }
    }
    
    func restart() {
        startDate = nil
    }
    
}
