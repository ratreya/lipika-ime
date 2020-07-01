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
    private var factory = try! LiteratorFactory(config: LipikaConfig())
    @ObservedObject var model = SettingsModel()

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Spacer(minLength: 5)
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("Use")
                        MenuButton(model.schemeName) {
                            ForEach(try! factory.availableSchemes(), id: \.self) { scheme in
                                Button(scheme) { self.model.schemeName = scheme }
                            }
                        }
                        .padding(0)
                        .fixedSize()
                        Text("to transliterate into")
                        MenuButton(model.scriptName) {
                            ForEach(model.languages, id: \.self) { script in
                                Button(script.language) { self.model.scriptName = script.identifier }
                            }
                        }
                        .padding(0)
                        .fixedSize()
                    }
                    VStack(alignment: .center, spacing: 4) {
                        HStack {
                            Text("If you type")
                            TextField("\\", text: $model.stopString)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .border(Color.red, width: model.stopCharacterInvalid ? 2 : 0)
                            .frame(width: 30)
                            Text("then output what you have so far and process all subsequent inputs afresh")
                        }
                        Text("For example, typing ai will output \(model.transliterate("ai")) but typing a\(model.stopString)i will output \(model.stopCharacterExample)").font(.caption)
                    }
                    .fixedSize()
                    HStack {
                        Text("Any character typed between")
                        TextField("`", text: $model.escapeString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .border(Color.red, width: model.escapeCharacterInvalid ? 2 : 0)
                        .frame(width: 30)
                        Text("will be output as-is in alphanumeric")
                    }
                    HStack {
                        Text("Output logs to the console at")
                        MenuButton(model.logLevelString) {
                            ForEach(Logger.Level.allCases, id: \.self) { (level) in
                                Button(level.rawValue) { self.model.logLevelString = level.rawValue }
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
                        Toggle(isOn: $model.showCandidates) {
                            HStack {
                                Text("Display a pop-up candidates window that shows the")
                                MenuButton(model.outputInClient ? "Input" : "Output") {
                                    Button("Input") { self.model.outputInClient = true }
                                    Button("Output") { self.model.outputInClient = false }
                                }
                                .padding(0)
                                .scaledToFit()
                            }
                        }
                        Text("Shows\(model.showCandidates ? "\(model.outputInClient ? " input" : " output") in candidate window and" : "") \(model.outputInClient ? "output" : "input") in editor")
                            .font(.caption)
                            .padding(.leading, 18)
                    }
                    .fixedSize()
                    VStack(alignment: .leading, spacing: 18) {
                        Toggle(isOn: $model.globalScriptSelection) {
                            Text("New Script selection to apply to all applications as opposed to just the one in the foreground")
                        }
                        Toggle(isOn: $model.activeSessionOnDelete) {
                            Text("When you backspace, start a new session with the word being edited")
                        }.disabled(model.outputInClient)
                        Toggle(isOn: $model.activeSessionOnInsert) {
                            Text("When you type inbetween a word, start a new session with the word being edited")
                        }.disabled(model.outputInClient)
                        Toggle(isOn: $model.activeSessionOnCursorMove) {
                            Text("When you move the caret over a word, start a new session with that word")
                        }.disabled(model.outputInClient)
                    }
                }
            }
            Spacer(minLength: 38)
            PersistenceView(model: model, context: "settings")
            Spacer(minLength: 25)
        }.padding(20)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
