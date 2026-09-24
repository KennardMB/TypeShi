//
//  SettingsView.swift
//  TypeUp
//
//  Created by Kennard M on 09/09/26.
//

import SwiftUI

struct SettingsView: View {
    @Bindable var settings: SettingsViewModel
    /// Pushes the toggles into the typing session.
    var apply: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle("Punctuation", isOn: $settings.punctuation)
                .toggleStyle(.switch)
            Toggle("Capitalization", isOn: $settings.capitalization)
                .toggleStyle(.switch)

            VStack(alignment: .leading, spacing: 6) {
                Text("Word list")
                Picker("Word list", selection: $settings.corpus) {
                    ForEach(TypingViewModel.Corpus.allCases) { corpus in
                        Text(corpus.title).tag(corpus)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            Text("If a test is running, this applies when you restart.")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .font(.system(size: 13, design: .monospaced))
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationTitle("Settings")
        .onChange(of: settings.punctuation) { _, _ in apply() }
        .onChange(of: settings.capitalization) { _, _ in apply() }
        .onChange(of: settings.corpus) { _, _ in apply() }
    }
}

#Preview {
    @Previewable @State var settings = SettingsViewModel()
    NavigationStack {
        SettingsView(settings: settings, apply: {})
    }
}
