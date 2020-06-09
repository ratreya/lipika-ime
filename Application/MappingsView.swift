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
    @Published var isDirty = false
    @Published var isFactory = false
    @Published var mappings: [[String]] {
        didSet {
            self.reeval()
        }
    }
    
    init() {
        let config = LipikaConfig()
        factory = try! LiteratorFactory(config: config)
        scheme = config.schemeName
        script = config.scriptName
        mappings = MappingModel.storedMappings(scheme: scheme, script: script)
        reeval()
    }
    
    static func storedMappings(scheme: String, script: String) -> [[String]] {
        if let mappings: [[String]] = MappingStore.read(schemeName: scheme, scriptName: script) {
            return mappings
        }
        else {
            let factory = try! LiteratorFactory(config: LipikaConfig())
            let nested = try! factory.mappings(schemeName: scheme, scriptName: script)
            return MappingStore.denest(nested: nested)
        }
    }
    
    private func reeval() {
        isDirty = self.mappings != MappingModel.storedMappings(scheme: scheme, script: script)
        if let _: [[String]] = MappingStore.read(schemeName: scheme, scriptName: script) {
            isFactory = false
        }
        else {
            isFactory = true
        }
    }

    func save() {
        if !MappingStore.write(schemeName: scheme, scriptName: script, mappings: mappings) {
            Logger.log.error("Unable to write to MappingStore for \(scheme) and \(script)")
        }
        reeval()
    }
    
    func loadMappings() {
        self.mappings = MappingModel.storedMappings(scheme: scheme, script: script)
    }
    
    func reset() {
        MappingStore.delete(schemeName: scheme, scriptName: script)
        loadMappings()
    }
}

struct MappingsView: View {
    @ObservedObject var model = MappingModel()
    @State var confirmDiscard = false
    @State var confirmReset = false
    
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
                    self.model.save()
                }
                .padding([.leading, .trailing], 10)
                .disabled(!model.isDirty)
                Button("Discard Changes") {
                    self.confirmDiscard = true
                }
                .alert(isPresented: $confirmDiscard) {
                    Alert(title: Text("Discard current changes?"), message: Text("Do you wish to discard all changes you just made to \(model.scheme) mappings for \(model.script)?"), primaryButton: .destructive(Text("Discard"), action: { self.model.loadMappings() }), secondaryButton: .cancel(Text("Cancel")))
                }
                .padding([.leading, .trailing], 10)
                .disabled(!model.isDirty)
                Button("Factory Defaults") {
                    self.confirmReset = true
                }
                .alert(isPresented: $confirmReset) {
                    Alert(title: Text("Reset to Factory Defaults?"), message: Text("Do you wish to discard all changes ever made to \(model.scheme) mappings for \(model.script) and reset to factory defaults? This does not affect other mappings for different schemes and languages."), primaryButton: .destructive(Text("Reset"), action: { self.model.reset() }), secondaryButton: .cancel(Text("Cancel")))
                }
                .padding([.leading, .trailing], 10)
                .disabled(model.isFactory)
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
