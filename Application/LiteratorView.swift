/*
* LipikaApp is companion application for LipikaIME.
* Copyright (C) 2020 Ranganath Atreya
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

import SwiftUI
import AppKit
import LipikaEngine_OSX

struct MultilineTextView: NSViewRepresentable {
    typealias NSViewType = NSTextView

    @Binding var text: String
    var isEditable: Bool

    func makeNSView(context: Self.Context) -> Self.NSViewType{
        let view = NSTextView()
        view.isEditable = isEditable
        view.isRulerVisible = true
        view.delegate = context.coordinator
        return view
    }

    func updateNSView(_ nsView: Self.NSViewType, context: Self.Context) {
        if nsView.string != text {
            nsView.string = text
        }
    }
    
    func makeCoordinator() -> Controller {
        return Controller(self)
    }
    
    class Controller: NSObject, NSTextViewDelegate {
        var wrapper: MultilineTextView
        
        init(_ wrapper: MultilineTextView) {
            self.wrapper = wrapper
        }
        
        func textDidChange(_ notification: Notification) {
            guard let view = notification.object as? NSTextView else { return }
            if wrapper.text != view.string {
                wrapper.text = view.string
            }
        }
    }
}

class LiteratorModel: ObservableObject {
    private let factory: LiteratorFactory
    private var trans: Transliterator?
    private var ante: Anteliterator?
    private var eval: (String) -> String
    
    @Published var inputSelection = 0 { didSet { self.reeval() }}
    @Published var outputSelection = 1 { didSet { self.reeval() }}

    @Published var fromScheme: String { didSet { self.reeval() }}
    @Published var toScheme: String { didSet { self.reeval() }}
    @Published var fromScript: String { didSet { self.reeval() }}
    @Published var toScript: String { didSet { self.reeval() }}

    init() {
        let settings = LipikaConfig()
        fromScheme = settings.schemeName
        fromScript = settings.scriptName
        toScheme = settings.schemeName
        toScript = settings.scriptName
        factory = try! LiteratorFactory(config: settings)
        eval = { (_: String) -> String in return "" } // Dummy initialization
        reeval()
    }
    
    func reeval() {
        switch ((inputSelection, outputSelection)) {
        case (0, 0):
            self.trans = try! self.factory.transliterator(schemeName: self.fromScheme, scriptName: "Devanagari")
            self.ante = try! self.factory.anteliterator(schemeName: self.toScheme, scriptName: "Devanagari")
            eval = { (input: String) -> String in
                _ = self.trans!.reset()
                let lit = self.trans!.transliterate(input)
                return self.ante!.anteliterate(lit.finalaizedOutput + lit.unfinalaizedOutput)
            }
        case (0, 1):
            let override: [String: MappingValue]? = MappingStore.read(schemeName: self.fromScheme, scriptName: self.toScript)
            self.trans = try! self.factory.transliterator(schemeName: self.fromScheme, scriptName: self.toScript, mappings: override)
            eval = { (input: String) -> String in
                _ = self.trans!.reset()
                let lit = self.trans!.transliterate(input)
                return lit.finalaizedOutput + lit.unfinalaizedOutput
            }
        case (1, 0):
            let override: [String: MappingValue]? = MappingStore.read(schemeName: self.toScheme, scriptName: self.fromScript)
            self.ante = try! self.factory.anteliterator(schemeName: self.toScheme, scriptName: self.fromScript, mappings: override)
            eval = { (input: String) -> String in
                return self.ante!.anteliterate(input)
            }
        case (1, 1):
            self.ante = try! self.factory.anteliterator(schemeName: "Barahavat", scriptName: self.fromScript)
            self.trans = try! self.factory.transliterator(schemeName: "Barahavat", scriptName: self.toScript)
            eval = { (input: String) -> String in
                _ = self.trans!.reset()
                let lit = self.trans!.transliterate(self.ante!.anteliterate(input))
                return lit.finalaizedOutput + lit.unfinalaizedOutput
            }
        default:
            Logger.log.fatal("Unknown combination of (inputSelection, outputSelection): \((inputSelection, outputSelection))")
            fatalError()
        }
        self.output = eval(self.input)
    }

    @Published var input = "" { didSet {
        self.output = eval(self.input)
    }}
    @Published var output = ""
}

struct LiteratorView: View {
    private let settings: LipikaConfig
    private let factory: LiteratorFactory
    @ObservedObject var model = LiteratorModel()

    init() {
        self.settings = LipikaConfig()
        self.factory = try! LiteratorFactory(config: settings)
    }
    
    var body: some View {
        GeometryReader { geometry in
            HSplitView {
                VStack (alignment: .leading) {
                    Picker("", selection: self.$model.inputSelection) {
                        HStack {
                            Text("Scheme")
                            MenuButton(self.model.fromScheme) {
                                ForEach(try! self.factory.availableSchemes(), id: \.self) { scheme in
                                    Button(scheme) { self.model.fromScheme = scheme }
                                }
                            }
                            .fixedSize()
                            .disabled(self.model.inputSelection == 1)
                        }
                        .tag(0)
                        .pickerStyle(PopUpButtonPickerStyle())
                        HStack {
                            Text("Script")
                            MenuButton(self.model.fromScript) {
                                ForEach(try! self.factory.availableScripts(), id: \.self) { script in
                                    Button(script) { self.model.fromScript = script }
                                }
                            }
                            .fixedSize()
                            .disabled(self.model.inputSelection == 0)
                        }
                        .tag(1)
                        .pickerStyle(PopUpButtonPickerStyle())
                    }
                    .pickerStyle(RadioGroupPickerStyle())
                    Spacer(minLength: 20)
                    MultilineTextView(text: self.$model.input, isEditable: true)
                }
                .padding()
                .frame(minWidth: geometry.size.width/3, idealWidth: geometry.size.width/2)
                VStack (alignment: .leading) {
                    Picker("", selection: self.$model.outputSelection) {
                        HStack {
                            Text("Scheme")
                            MenuButton(self.model.toScheme) {
                                ForEach(try! self.factory.availableSchemes(), id: \.self) { scheme in
                                    Button(scheme) { self.model.toScheme = scheme }
                                }
                            }
                            .fixedSize()
                            .disabled(self.model.outputSelection == 1)
                        }
                        .tag(0)
                        .pickerStyle(PopUpButtonPickerStyle())
                        HStack {
                            Text("Script")
                            MenuButton(self.model.toScript) {
                                ForEach(try! self.factory.availableScripts(), id: \.self) { script in
                                    Button(script) { self.model.toScript = script }
                                }
                            }
                            .fixedSize()
                            .disabled(self.model.outputSelection == 0)
                        }
                        .tag(1)
                        .pickerStyle(PopUpButtonPickerStyle())
                    }
                    .pickerStyle(RadioGroupPickerStyle())
                    Spacer(minLength: 20)
                    MultilineTextView(text: self.$model.output, isEditable: false)
                    .disabled(true)
                }
                .padding()
                .frame(minWidth: geometry.size.width/3, idealWidth: geometry.size.width/2)
            }
        }
        .padding()
    }
}

struct LiteratorView_Previews: PreviewProvider {
    static var previews: some View {
        LiteratorView()
    }
}
