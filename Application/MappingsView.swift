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
        didSet { self.reload() }
    }
    var script: String {
        didSet { self.reload() }
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
    
    func reload() {
        self.mappings = MappingModel.storedMappings(scheme: scheme, script: script)
    }
    
    func reset() {
        MappingStore.delete(schemeName: scheme, scriptName: script)
        reload()
    }
}

struct MappingsView: View {
    @ObservedObject var model = MappingModel()
    @State var confirmDiscard = false
    @State var confirmReset = false
    @State var saveError = false
    @State var openError = false
    
    var body: some View {
        VStack {
            Spacer(minLength: 25)
            HStack {
                Text("For scheme")
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.leading, .trailing], 16)
            Spacer(minLength: 10)
            HStack(alignment: .center, spacing: 5) {
                Group {
                    Button("\u{2191}") {
                        let savePanel = NSSavePanel()
                        savePanel.title = "Export Mappings"
                        savePanel.message = "Export Mappings for \(self.model.scheme) and \(self.model.script)"
                        savePanel.nameFieldStringValue = "\(self.model.scheme)-\(self.model.script).ime"
                        savePanel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
                        savePanel.showsTagField = false
                        savePanel.allowedFileTypes = ["ime"]
                        savePanel.allowsOtherFileTypes = false
                        savePanel.canCreateDirectories = false
                        savePanel.canCreateDirectories = false
                        savePanel.begin() { (result) -> Void in
                            if result == NSApplication.ModalResponse.OK, let file = savePanel.url {
                                if let data = try? JSONEncoder().encode(self.model.mappings) {
                                    self.saveError = !FileManager.default.createFile(atPath: file.path, contents: data)
                                }
                                else {
                                    self.saveError = true
                                }
                            }
                        }
                    }
                    .alert(isPresented: $saveError) {
                        Alert(title: Text("I/O Error"), message: Text("Error writing mappings to file."), dismissButton: .default(Text("OK")))
                    }
                    Button("\u{2193}") {
                        let openPanel = NSOpenPanel()
                        openPanel.title = "Import Mappings"
                        openPanel.message = "Import Mappings for \(self.model.scheme) and \(self.model.script)"
                        openPanel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
                        openPanel.allowedFileTypes = ["ime"]
                        openPanel.allowsOtherFileTypes = false
                        openPanel.allowsMultipleSelection = false
                        openPanel.canChooseDirectories = false
                        openPanel.canCreateDirectories = false
                        openPanel.canChooseFiles = true
                        openPanel.begin { (result) -> Void in
                            if result == NSApplication.ModalResponse.OK, let file = openPanel.url {
                                if let data = try? Data(contentsOf: file), let mappings = try? JSONDecoder().decode([[String]].self, from: data) {
                                    self.model.mappings = mappings
                                }
                                else {
                                    self.openError = true
                                }
                            }
                        }
                    }
                    .alert(isPresented: $openError) {
                        Alert(title: Text("I/O Error"), message: Text("Error reading mappings from file."), dismissButton: .default(Text("OK")))
                    }

                }
                .buttonStyle(PlainButtonStyle())
                .padding(0)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 16).padding(.top, -20)
            MappingTable(mappings: $model.mappings).padding([.leading, .bottom, .trailing], 16)
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
                    Alert(title: Text("Discard current changes?"), message: Text("Do you wish to discard all changes you just made to \(model.scheme) mappings for \(model.script)?"), primaryButton: .destructive(Text("Discard"), action: { self.model.reload() }), secondaryButton: .cancel(Text("Cancel")))
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
