/*
* LipikaApp is companion application for LipikaIME.
* Copyright (C) 2020 Ranganath Atreya
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

import SwiftUI
import LipikaEngine_OSX
import Carbon.HIToolbox.Events

class LanguageModel: ObservableObject {
    @Published var mappings: [LanguageConfig] {
        didSet {
            self.reeval()
        }
    }
    @Published var isDirty = false
    @Published var isFactory = false
    let config = LipikaConfig()

    init() {
        mappings = config.languageConfig
        reeval()
    }
    
    private func reeval() {
        isDirty = mappings != config.languageConfig
        isFactory = config.languageConfig == config.factoryLanguageConfig
    }
    
    func save() {
        config.languageConfig = mappings
        reeval()
    }
    
    func reload() {
        mappings = config.languageConfig
    }
    
    func reset() {
        config.resetLanguageConfig()
        reload()
    }
}

struct LanguageView: View {
    @ObservedObject var model = LanguageModel()
    @State var confirmDiscard = false
    @State var confirmReset = false

    var body: some View {
        VStack {
            LanguageTable(mappings: $model.mappings)
                .padding(16)
            Spacer(minLength: 10)
            HStack {
                Button("Save Changes") {
                    self.model.save()
                }
                .padding([.leading, .trailing], 10)
                .disabled(!model.isDirty)
                Button("Discard Changes") {
                    self.confirmDiscard = true
                }
                .alert(isPresented: $confirmDiscard) {
                    Alert(title: Text("Discard current changes?"), message: Text("Do you wish to discard all changes you just made to language configuration?"), primaryButton: .destructive(Text("Discard"), action: { self.model.reload() }), secondaryButton: .cancel(Text("Cancel")))
                }
                .padding([.leading, .trailing], 10)
                .disabled(!model.isDirty)
                Button("Factory Defaults") {
                    self.confirmReset = true
                }
                .alert(isPresented: $confirmReset) {
                    Alert(title: Text("Reset to Factory Defaults?"), message: Text("Do you wish to discard all changes ever made to language configuration and reset to factory defaults?"), primaryButton: .destructive(Text("Reset"), action: { self.model.reset() }), secondaryButton: .cancel(Text("Cancel")))
                }
                .padding([.leading, .trailing], 10)
                .disabled(model.isFactory)
            }
            Spacer(minLength: 25)
        }
    }
}

struct LanguageView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageView()
    }
}
