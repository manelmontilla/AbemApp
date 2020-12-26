//
//  ActivityIndicator.swift
//  AbemApp (macOS)
//
//  Created by Manel Montilla on 22/12/20.
//

import Foundation
import SwiftUI
struct ActivityIndicator: NSViewRepresentable  {

    @Binding var isAnimating: Bool
    typealias TheNSView = NSProgressIndicator
    var configuration = { (view: TheNSView) in }
    
    func makeNSView(context: NSViewRepresentableContext<ActivityIndicator>) -> NSProgressIndicator {
        TheNSView()
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ActivityIndicator>) {
        configuration(nsView)
    }
}
