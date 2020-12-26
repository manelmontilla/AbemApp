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
    var ext:  String
    init(from content: Data,_ fileExtension:String="") {
        self.content = content
        self.ext = fileExtension
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.content = data
        self.ext = ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        var fw = FileWrapper(regularFileWithContents: content)
        fw.preferredFilename = "file."+self.ext
        return fw
    }
    
}
