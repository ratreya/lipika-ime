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

struct SettingsView: View {
    @ObservedObject var settings = Settings()
    private var factory = try! LiteratorFactory(config: LipikaConfig())
    
    func transliterate(_ input: String) -> String {
        let transliterator = try! factory.transliterator(schemeName: settings.schemeName, scriptName: settings.scriptName)
        let output = transliterator.transliterate(input)
        return output.finalaizedOutput + output.unfinalaizedOutput
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 17) {
                    HStack {
                        Text("Use")
                        MenuButton(settings.schemeName) {
                            ForEach(try! factory.availableSchemes(), id: \.self) { scheme in
                                Button(scheme) { self.settings.schemeName = scheme }
                            }
                        }
                        .padding(0)
                        .fixedSize()
                        Text("to transliterate into")
                        MenuButton(settings.scriptName) {
                            ForEach(try! factory.availableScripts(), id: \.self) { script in
                                Button(script) { self.settings.scriptName = script }
                            }
                        }
                        .padding(0)
                        .fixedSize()
                    }
                    VStack(alignment: .center, spacing: 4) {
                        HStack {
                            Text("If you type")
                            TextField("`", text: $settings.stopCharacter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .border(Color.red, width: settings.stopCharacterInvalid ? 2 : 0)
                            .frame(width: 30)
                            Text("then output what you have so far and process all subsequent inputs afresh")
                        }
                        Text("For example, typing ai will output \(transliterate("ai")) but typing a\(settings.stopCharacter)i will output \(transliterate("a\(settings.stopCharacter)i"))").font(.caption)
                    }
                    .fixedSize()
                    HStack {
                        Text("Any character typed between")
                        TextField("\\", text: $settings.escapeCharacter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .border(Color.red, width: settings.escapeCharacterInvalid ? 2 : 0)
                        .frame(width: 30)
                        Text("will be output as-is in alphanumeric")
                    }
                    HStack {
                        Text("Output logs to the console at")
                        MenuButton(settings.logLevel) {
                            ForEach(Logger.Level.allCases, id: \.self) { (level) in
                                Button(level.rawValue) { self.settings.logLevel = level.rawValue }
                            }
                        }
                        .fixedSize()
                        .padding(0)
                        Text("- Debug is most verbose and Fatal is least verbose")
                    }
                }
                Divider()
                Group {
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle(isOn: $settings.showCandidates) {
                            HStack {
                                Text("Display a pop-up candidates window that shows the")
                                MenuButton(settings.outputInClient ? "Input" : "Output") {
                                    Button("Input") { self.settings.outputInClient = true }
                                    Button("Output") { self.settings.outputInClient = false }
                                }
                                .padding(0)
                                .scaledToFit()
                            }
                        }
                        Text("Shows\(settings.showCandidates ? "\(settings.outputInClient ? " input" : " output") in candidate window and" : "") \(settings.outputInClient ? "output" : "input") in editor")
                            .font(.caption)
                            .padding(.leading, 18)
                    }
                    .fixedSize()
                    VStack(alignment: .leading, spacing: 17) {
                        Toggle(isOn: $settings.globalScriptSelection) {
                            Text("New Script selection to apply to all applications as opposed to just the one in the foreground")
                        }
                        Toggle(isOn: $settings.activeSessionOnDelete) {
                            Text("When you backspace, start a new session with the word being edited")
                        }
                        Toggle(isOn: $settings.activeSessionOnInsert) {
                            Text("When you type inbetween a word, start a new session with the word being edited")
                        }
                        Toggle(isOn: $settings.activeSessionOnCursorMove) {
                            Text("When you move the caret over a word, start a new session with that word")
                        }
                    }
                }
            }
            Spacer(minLength: 35)
            HStack {
                Button("Save Changes") {
                    self.settings.save()
                }
                .disabled(!settings.isDirty || settings.stopCharacterInvalid || settings.escapeCharacterInvalid)
                .padding([.leading, .trailing], 10)
                Button("Discard Changes") {
                    self.settings.reset()
                }
                .padding([.leading, .trailing], 10)
                .disabled(!settings.isDirty)
                Button("Factory Defaults") {
                    self.settings.defaults()
                }
                .padding([.leading, .trailing], 10)
                .disabled(settings.isFactory)
            }
            Spacer(minLength: 25)
        }.padding(20)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
