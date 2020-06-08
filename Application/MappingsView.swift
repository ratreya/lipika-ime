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

class MappingModel: ObservableObject {
    var factory: LiteratorFactory
    var scheme: String {
        didSet { self.loadMappings() }
    }
    var script: String {
        didSet { self.loadMappings() }
    }
    @Published var mappings: [[String]]!
    
    init() {
        let config = LipikaConfig()
        factory = try! LiteratorFactory(config: config)
        scheme = config.schemeName
        script = config.scriptName
        loadMappings()
    }

    func loadMappings() {
        if let mappings: [[String]] = MappingStore.read(schemeName: scheme, scriptName: script) {
            self.mappings = mappings
        }
        else {
            let nested = try! factory.mappings(schemeName: scheme, scriptName: script)
            self.mappings = MappingStore.denest(nested: nested)
        }
    }

}

struct MappingsView: View {
    @ObservedObject var model = MappingModel()
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer(minLength: 25)
            HStack {
                Text("Edit mappigs for scheme")
                MenuButton(model.scheme) {
                    ForEach(try! model.factory.availableSchemes(), id: \.self) { scheme in
                        Button(scheme) { self.model.scheme = scheme }
                    }
                }
                .padding(0)
                .fixedSize()
                Text("and script")
                MenuButton(model.script) {
                    ForEach(try! model.factory.availableScripts(), id: \.self) { script in
                        Button(script) { self.model.script = script }
                    }
                }
                .padding(0)
                .fixedSize()
            }
            Spacer(minLength: 15)
            TableView(mappings: $model.mappings)
            .padding()
            Spacer(minLength: 20)
            HStack {
                Button("Save Changes") {
                }
                .padding([.leading, .trailing], 10)
                Button("Discard Changes") {
                }
                .padding([.leading, .trailing], 10)
                Button("Factory Defaults") {
                }
                .padding([.leading, .trailing], 10)
            }
            Spacer(minLength: 25)
        }
    }
}

struct MappingsView_Previews: PreviewProvider {
    static var previews: some View {
        MappingsView()
        .frame(width: 660, height: 520)
    }
}
