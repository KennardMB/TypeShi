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
    
    // case for judge
    enum LetterState {
        case untyped
        case correct
        case incorrect
        case extraIncorrect
    }
    
    var selectedDuration: Duration = .fifteen
    private(set) var startDate: Date?
    var isFinished: Bool = false
    
    //Keypress
    var typedBuffer: String = ""
    
    //Judge
    private(set) var currentIndex: Int = 0
    
    // TypingView Logic
    private let bank : [String]
    var words: [String] = []
    
    init() {
        bank = Self.loadBank()
        generatePrompt()
    }
    
    
    private static func loadBank() -> [String] {
// this gets the en_1k.json path
        let url = Bundle.main.url(forResource: "en_1k", withExtension: "json")
        ?? Bundle.main.url(forResource: "en_1k", withExtension: "json", subdirectory: "Resources")
        // this says "if you have url (path), then continue as URL (fixed)
        guard let url else { return [] }
        do {
            //getting contents of the path (JSON)
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([String].self, from: data)
        } catch {
            return []
        }
        
    }
    
    
    //TIMER
    func remainingSeconds(at now: Date) -> Int {
        guard let startDate else {
            return selectedDuration.rawValue
        }
        let elapsed = now.timeIntervalSince(startDate)
        let remaining = max(0, selectedDuration.rawValue - Int(elapsed))
        if remaining == 0 {
            isFinished = true
        }
        return remaining
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
    
    //Keypress function & Judge
    func handleTypedCharacters(_ characters: String) {
        let letters = characters.filter { !$0.isWhitespace }
        guard !letters.isEmpty else { return }
        beginCountdown()
        typedBuffer.append(contentsOf: letters)
    }
    
    func handleBackspace() {
        guard !typedBuffer.isEmpty else { return }
        typedBuffer.removeLast()
    }
    
    func commitWord() {
        guard !typedBuffer.isEmpty else { return }
        currentIndex += 1
        typedBuffer = ""
    }
    
    // JUDGE JUDY
    func letterState(at index: Int) -> LetterState {
        guard currentIndex < words.count else { return .untyped}
        let target = words[currentIndex]
        let targetChars = Array(target)
        let bufferChars = Array(typedBuffer)
        
        if index >= bufferChars.count { return .untyped}
        if index >= targetChars.count { return .extraIncorrect }
        return bufferChars[index] == targetChars[index] ? .correct : .incorrect
    }
    
    //word randomizer takes 200 words from bank
    private func generatePrompt() {
        words = Array(bank.shuffled().prefix(200))
    }

    
    func restart() {
        startDate = nil
        typedBuffer = ""
        currentIndex = 0
        generatePrompt()
        isFinished = false
    }
    
}
