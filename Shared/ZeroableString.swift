//
//  ZeroableObject.swift
//  AbemApp
//
//  Created by Manel Montilla on 24/12/20.
//

import Foundation

class ZeroableString: ObservableObject {
    @Published  var val: String
    
    init (_ val: String) {
        self.val = val
    }
    func zero(with zeroVal: Character) {
        // Try to do our best to override the current stored string but there are no guaranties.
        let zeroChars = (0..<self.val.count).map { index in
            zeroVal
        }
        let zeroStr = String(zeroChars)
        let index = self.val.index(self.val.startIndex, offsetBy:0)
        let lastIndex = self.val.index(self.val.startIndex, offsetBy: self.val.count-1)
        self.val.replaceSubrange(index...lastIndex, with: zeroStr)
    }
}
