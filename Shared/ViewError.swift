//
//  ViewError.swift
//  AbemApp
//
//  Created by Manel Montilla on 27/12/20.
//

import Foundation


enum ViewError:Error {
    case LogicalError(description: String)
}

extension ViewError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .LogicalError(let description):
            return NSLocalizedString(description,comment: "")
        }
    }
}
