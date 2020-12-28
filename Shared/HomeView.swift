//
//  HomeView.swift
//  AbemApp
//
//  Created by Manel Montilla on 25/12/20.
//

import Foundation
import SwiftUI
import Parma

struct HomeView: View {
    
    var body: some View {
        
        TabView() {
           
            FileEncryptionView()
                .tabItem {
                    Image(systemName: "lock")
                    Text("Encrypt")
                }
            
            FileDecryptionView()
                .tabItem {
                    Image(systemName: "lock.open")
                    Text("Dencrypt")
                }
            HelpView()
                .tabItem {
                Image(systemName:"questionmark")
                Text("Help")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
        }
    }
}
