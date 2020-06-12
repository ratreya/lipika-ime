/*
* LipikaApp is companion application for LipikaIME.
* Copyright (C) 2020 Ranganath Atreya
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

import SwiftUI

struct MainView: View {
    @State private var currentTab = 0
    
    var body: some View {
        TabView(selection: $currentTab) {
            LiteratorView().tabItem {
                Text("Transliterator")
            }.tag(0)
            .onAppear() {
                self.currentTab = 0
            }
            MappingsView().tabItem {
                Text("Mapping")
            }.tag(1)
            .onAppear() {
                self.currentTab = 1
            }
            SettingsView().tabItem {
                Text("Settings")
            }.tag(2)
            .onAppear() {
                self.currentTab = 2
            }
        }.padding(20)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
