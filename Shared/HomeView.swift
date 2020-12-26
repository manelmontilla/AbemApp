//
//  HomeView.swift
//  AbemApp
//
//  Created by Manel Montilla on 25/12/20.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            Text("Help")
                .tabItem {
                    Image(systemName:"questionmark")
                    Text("Help")
                }
            
        }.accentColor(.blue)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
        }
    }
}
