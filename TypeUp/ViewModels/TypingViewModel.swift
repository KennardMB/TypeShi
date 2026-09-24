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
    
    //Keypress
    var typedBuffer: String = ""
    
    //Judge
    private(set) var currentIndex: Int = 0
    
    // Remember how many words were exact; expose WPM
    private(set) var correctWordCount: Int = 0

    // Each committed word, so backspace can restore it (slice H).
    private var committedBuffers: [String] = []

    // Inputs from Settings. The generator reads these; the judge does not.
    private(set) var promptOptions = PromptOptions()
    
    var wpm: Int {
        let minutes = Double(selectedDuration.rawValue) / 60.0
        guard minutes > 0 else { return 0 }
        return Int((Double(correctWordCount) / minutes).rounded())
    }
    
    
    // TypingView Logic
    private let bank1k: [String]
    private let bank5k: [String]
    var words: [String] = []

    struct PromptOptions: Equatable {
        var punctuation = false
        var capitalization = false
        var corpus: Corpus = .oneThousand
    }

    enum Corpus: String, CaseIterable, Identifiable {
        case oneThousand
        case fiveThousand

        var id: Self { self }

        var title: String {
            switch self {
            case .oneThousand: return "1,000"
            case .fiveThousand: return "5,000"
            }
        }

        fileprivate var resourceName: String {
            switch self {
            case .oneThousand: return "en_1k"
            case .fiveThousand: return "en_5k"
            }
        }
    }
    
    init() {
        bank1k = Self.loadBank(named: Corpus.oneThousand.resourceName)
        bank5k = Self.loadBank(named: Corpus.fiveThousand.resourceName)
        generatePrompt()
    }
    
    
    private static func loadBank(named name: String) -> [String] {
// this gets the JSON word-list path
        let url = Bundle.main.url(forResource: name, withExtension: "json")
        ?? Bundle.main.url(forResource: name, withExtension: "json", subdirectory: "Resources")
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
        return max(0, selectedDuration.rawValue - Int(elapsed))
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
        guard remainingSeconds(at: .now) > 0 else { return }
        beginCountdown()
        typedBuffer.append(contentsOf: letters)
    }
    
    func handleBackspace() {
        guard remainingSeconds(at: .now) > 0 else { return }
        if typedBuffer.isEmpty {
            // Un-commit the previous word and put its letters back.
            guard currentIndex > 0, !committedBuffers.isEmpty else { return }
            currentIndex -= 1
            let restored = committedBuffers.removeLast()
            if currentIndex < words.count, restored == words[currentIndex] {
                correctWordCount = max(0, correctWordCount - 1)
            }
            typedBuffer = restored
            return
        }
        typedBuffer.removeLast()
    }
    
    func commitWord() {
        guard !typedBuffer.isEmpty else { return }
        guard remainingSeconds(at: .now) > 0 else { return }
        if currentIndex < words.count, typedBuffer == words[currentIndex] {
            correctWordCount += 1
        }
        committedBuffers.append(typedBuffer)
        currentIndex += 1
        typedBuffer = ""
    }

    func committedTyped(at index: Int) -> String {
        guard committedBuffers.indices.contains(index) else { return "" }
        return committedBuffers[index]
    }

    /// Settings are a filter on the next list. A running test keeps its current words.
    func updateOptions(_ options: PromptOptions) {
        let changed = options != promptOptions
        promptOptions = options
        guard changed, startDate == nil else { return }
        typedBuffer = ""
        currentIndex = 0
        correctWordCount = 0
        generatePrompt()
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
    
    // Same draw as Monkeytype's default test: the 200 most common words,
    // each one equally likely. A word may appear again, but not twice in a row.
    private func generatePrompt() {
        let pool = promptOptions.corpus == .fiveThousand && !bank5k.isEmpty ? bank5k : bank1k
        let common = Array(pool.prefix(200))
        var picked: [String] = []
        picked.reserveCapacity(200)
        var previous: String?
        while picked.count < 200, !common.isEmpty {
            guard let word = common.randomElement() else { break }
            if word == previous, common.count > 1 { continue }
            picked.append(word)
            previous = word
        }
        words = applySettings(to: picked)
        committedBuffers = []
    }

    /// Punctuation and capitalization change the target strings. Matching stays buffer vs word.
    private func applySettings(to source: [String]) -> [String] {
        guard promptOptions.punctuation || promptOptions.capitalization else { return source }

        var output: [String] = []
        output.reserveCapacity(source.count)
        var nextIsCapital = false
        var wordsUntilStop = Int.random(in: 6...14)

        for (index, original) in source.enumerated() {
            var word = original
            let isLast = index == source.count - 1

            if promptOptions.capitalization {
                let randomCap = Int.random(in: 0..<8) == 0
                if index == 0 || nextIsCapital || randomCap {
                    word = capitalizingFirst(word)
                }
            }
            nextIsCapital = false

            if promptOptions.punctuation, let last = word.last, last.isLetter {
                wordsUntilStop -= 1
                if wordsUntilStop <= 0 || isLast {
                    let endings = [".", ".", ".", "?", "!"]
                    word += endings.randomElement() ?? "."
                    nextIsCapital = promptOptions.capitalization
                    wordsUntilStop = Int.random(in: 6...14)
                } else if Int.random(in: 0..<6) == 0 {
                    word += ","
                }
            }

            output.append(word)
        }
        return output
    }

    private func capitalizingFirst(_ word: String) -> String {
        guard let first = word.first, first.isLetter else { return word }
        return String(first).uppercased() + word.dropFirst()
    }

    
    func restart() {
        startDate = nil
        typedBuffer = ""
        currentIndex = 0
        correctWordCount = 0
        committedBuffers = []
        generatePrompt()
    }
}
