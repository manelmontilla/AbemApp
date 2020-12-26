//
//  AbemFiile.swift
//  AbemApp
//
//  Created by Manel Montilla on 19/12/20.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct AbemDocument: FileDocument {
    
    
    static var readableContentTypes: [UTType] { [.data] }
    
    static var writableContentTypes: [UTType] = [.data]
    
    var content: Data
    var filename:  String
    init(from content: Data,_ filename:String="") {
        self.content = content
        self.filename = filename
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.content = data
        var filename = ""
        if configuration.file.filename != nil {
            filename = configuration.file.filename!
        }
        self.filename = filename
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        var fw = FileWrapper(regularFileWithContents: content)
        fw.preferredFilename = self.filename
        return fw
    }
    
}
