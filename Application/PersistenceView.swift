/*
* LipikaApp is companion application for LipikaIME.
* Copyright (C) 2020 Ranganath Atreya
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

import SwiftUI

protocol PersistenceModel: ObservableObject {
    var isValid: Bool { get }
    var isDirty: Bool { get }
    var isFactory: Bool { get }
    func save()
    func reload()
    func reset()
}

struct PersistenceView<Model>: View where Model: PersistenceModel {
    @ObservedObject var model: Model
    let context: String
    @State var confirmDiscard = false
    @State var confirmReset = false

    var body: some View {
        HStack {
            Button("Save Changes") {
                self.model.save()
            }
            .disabled(!model.isDirty || !model.isValid)
            .padding([.leading, .trailing], 10)
            Button("Discard Changes") {
                self.confirmDiscard = true
            }
            .alert(isPresented: $confirmDiscard) {
                Alert(title: Text("Discard current changes?"), message: Text("Do you wish to discard all changes you just made to \(context)?"), primaryButton: .destructive(Text("Discard"), action: { self.model.reload() }), secondaryButton: .cancel(Text("Cancel")))
            }
            .padding([.leading, .trailing], 10)
            .disabled(!model.isDirty)
            Button("Factory Defaults") {
                self.confirmReset = true
            }
            .alert(isPresented: $confirmReset) {
                Alert(title: Text("Reset to Factory Defaults?"), message: Text("Do you wish to discard all changes ever made to \(context) and reset to factory defaults?"), primaryButton: .destructive(Text("Reset"), action: { self.model.reset() }), secondaryButton: .cancel(Text("Cancel")))
            }
            .padding([.leading, .trailing], 10)
            .disabled(model.isFactory)
        }
    }
}
