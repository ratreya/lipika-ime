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

struct LanguageView: View {
    let config: LipikaConfig
    @State var mappings: [LanguageConfig]
    
    init() {
        config = LipikaConfig()
        _mappings = State(initialValue: config.languageConfig)
    }
    
    var body: some View {
        VStack {
            LanguageTable(mappings: $mappings)
                .padding()
            Spacer(minLength: 20)
            HStack {
                Button("Save Changes") {
                    self.config.languageConfig = self.mappings
                }
                .padding([.leading, .trailing], 10)
                Button("Discard Changes") {
                    self.mappings = self.config.languageConfig
                }
                .padding([.leading, .trailing], 10)
                Button("Factory Defaults") {
                    self.config.resetLanguageConfig()
                    self.mappings = self.config.languageConfig
                }
                .padding([.leading, .trailing], 10)
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
