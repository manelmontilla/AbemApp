//
//  RunningView.swift
//  AbemApp
//
//  Created by Manel Montilla on 18/12/20.
//

import SwiftUI
struct LoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var text: String
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)

                VStack {
                    Text(self.text)
                    #if os(macOS)
                    ActivityIndicator(isAnimating: .constant(true))
                    #else
                    ActivityIndicator(isAnimating: .constant(true), style:.large)
                    #endif
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)
        }
      }
    }

}
