//
//  HelpView.swift
//  AbemApp
//
//  Created by Manel Montilla on 27/12/20.
//

import Foundation
import SwiftUI
import Parma

struct HelpView: View {
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing:30) {
                Parma(self.readHelp())
                    .padding(.horizontal, 10)
            }.frame(minWidth: 0, maxWidth: .infinity)
        }.padding()
    }
    
    func readHelp() -> String {
        guard let fileURL = Bundle.main.url(forResource: "Help", withExtension: "md") else {
            return "No help found"
        }
        do {
            let fileContents = try String(contentsOf: fileURL)
            return fileContents
        }
        catch let error {
            return error.localizedDescription
        }
    }
}
