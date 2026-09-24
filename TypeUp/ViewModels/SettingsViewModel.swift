//
//  SettingsViewModel.swift
//  TypeUp
//
//  Created by Kennard M on 23/09/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    var punctuation = false
    var capitalization = false
    var corpus: TypingViewModel.Corpus = .oneThousand

    var options: TypingViewModel.PromptOptions {
        TypingViewModel.PromptOptions(
            punctuation: punctuation,
            capitalization: capitalization,
            corpus: corpus
        )
    }
}
