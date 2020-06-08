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
    @State private var currentTab = 3
    
    var body: some View {
        TabView(selection: $currentTab) {
            Text("Keyboard").tabItem {
                Text("Keyboard")
            }.tag(0)
            Text("Transliterator").tabItem {
                Text("Transliterator")
            }.tag(1)
            MappingsView().tabItem {
                Text("Mapping")
            }.tag(2)
            SettingsView().tabItem {
                Text("Settings")
            }.tag(3)
        }.padding(20)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
