//
//  ContentView.swift
//  Shared
//
//  Created by Manel Montilla on 11/12/20.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers
#if !os(macOS)
import MobileCoreServices
#else
import CoreServices
#endif
import abem

struct FileEncryptionView: View {
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    @State private var isEncrypting: Bool = false
    @State private var isDecrypting: Bool = false
    @State private var isAlertShowing: Bool = false
    @State private var alertText: String = ""
    @State private var alertTitle: String = ""
    @ObservedObject private var password = ZeroableString("")
    @State private var showPasswordError: Bool = false
    @State private var showPasswordOkey: Bool = false
    @State private var isLoading: Bool = false
    @State private var documentExportContent: AbemDocument? = nil
    @State private var documentExportType: UTType = UTType.data
    
    func showModalMessage(_ title:String, _ text:String) {
        self.alertTitle = title
        self.alertText = text
        self.isAlertShowing = true
    }
    
    func showModalError(_ text: String) {
        self.alertTitle = "Error"
        self.alertText = text
        // We cancel any possible encrypting or decrypting process.
        self.isDecrypting = false
        self.isEncrypting = false
        // Show the alert dialog.
        self.isAlertShowing = true
    }
    
    func onFileImportingSelected(result: Result<[URL], Error>)  {
        if case .failure(let failure) = result {
            showModalError(failure.localizedDescription)
            return
        }
        self.isLoading = true
        let selectedFiles = try! result.get()
        if self.isEncrypting {
            DispatchQueue.global(qos: .userInteractive).async {
                encryptFiles(selectedFiles: selectedFiles)
            }
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            decryptFiles(selectedFiles: selectedFiles)
        }
        return
    }
    
    func onFileExported(result: Result<URL, Error>)  {
        if case .failure = result {
            // Handle failure.
            return
        }
        let url = try! result.get()
        let filename = "\(url.lastPathComponent)"
        var text = ""
        if self.isDecrypting {
            text="Decrypted file saved to: \(filename)"
            self.isDecrypting = false
        } else {
            text="Encrypted file saved to: \(filename)"
            self.isEncrypting = false
        }
        self.showModalMessage("Action Finished",text)
    }
    
    
    func onTextPasswordChanged(_ newValue: String) {
        if newValue.count == 0 {
            self.showPasswordError = true
        }
        if PasswordStrength.Check(newValue) != .strong  {
            self.showPasswordError = true
        } else {
            self.showPasswordError = false
        }
    }
    
    func encryptFiles(selectedFiles files: [URL]?) {
        do {
            guard files != nil && files!.count > 0 else {
                throw  ViewError.LogicalError(description: "Select a file to encrypt")
            }
            guard self.password.val.count > 0 else {
                throw ViewError.LogicalError(description: "password can not be empty")
            }
            let file = files![0]
            var filename = file.lastPathComponent
            var content = try Data(contentsOf:file)
            var res:Abem.Ciphertext?
            res = try Abem.Encrypt(data: content, metadata: filename, with: password.val)
            content.resetBytes(in:0...content.count-1)
            filename = file.deletingPathExtension().appendingPathExtension("abem").lastPathComponent
            let encryptedFile = AbemDocument(from:res!.Combined(),filename)
            let title = "Task finished"
            let text = """
            The contents of the file have been encrypted.
            Save the ciphertext to a file.
            """
            DispatchQueue.main.sync {
                self.password.zero(with:"0")
                self.password.val = ""
                self.documentExportContent = encryptedFile
                self.documentExportType = .data
                self.showModalMessage(title, text)
            }
            
        } catch let error {
            DispatchQueue.main.sync {
                showModalError(error.localizedDescription)
            }
        }
        DispatchQueue.main.sync {
            self.isLoading = false
        }
    }
    
    func decryptFiles(selectedFiles files: [URL]?) {
        do {
            guard files != nil && files!.count > 0 else {
                throw  ViewError.LogicalError(description: "Select a file to encrypt")
            }
            guard self.password.val.count > 0 else {
                throw ViewError.LogicalError(description: "Password cannot be empty")
            }
            let file = files![0]
            let content = try Data(contentsOf:file)
            let ciphertext = Abem.Ciphertext(from: content)
            let clear = try Abem.Decrypt(ciphertext, with: password.val)
            // Set the type of the file to export to the original one.
            var ext = NSURL(fileURLWithPath: clear.metadata).pathExtension
            if ext == nil {
                ext = ""
            }
            var ut = ext!.GetUTType()
            if ut == nil {
                ut = UTType.data
            }
            let clearDocument = AbemDocument(from:clear.payload, clear.metadata)
            // Hack to be able to specify the extension of the file to export.
            AbemDocument.writableContentTypes.append(ut!)
            let title = "Task finished"
            let text  = """
                The content of the file has been decrypted.
                Now you will we asked to move those contents to a file
                of your choice.
                """
            DispatchQueue.main.sync {
                self.documentExportContent = clearDocument
                self.documentExportType = ut!
                self.showModalMessage(title, text)
            }
            
        } catch let error {
            DispatchQueue.main.sync {
                showModalError(error.localizedDescription)
            }
        }
        DispatchQueue.main.sync {
            self.isLoading = false
        }
    }
    
    
    var body: some View {
        LoadingView(isShowing: $isLoading){
            VStack(alignment:HorizontalAlignment.center) {
                Text("Abem").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold()
                Divider()
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                    SecureField("File Password",text:$password.val)
                        .onChange(of: password.val,perform: onTextPasswordChanged)
                        .padding().border(Color.blue)
                    
                    if showPasswordError {
                        Image(systemName: "exclamationmark.circle").foregroundColor(.red)
                    }
                    if showPasswordOkey {
                        Image(systemName: "checkmark.circle")
                    }
                    
                }).padding()
                if showPasswordError {
                    Text("Password is too weak.\nIt must have a least 8 characters and must include: upper and lower letters, numbers and symbols.").font(.callout).padding()
                }
                Spacer()
                HStack() {
                    Button(action: {
                        guard PasswordStrength.Check(password.val) == .strong else {
                            self.showPasswordError = true
                            return
                        }
                        self.isEncrypting = true
                        self.isImporting = true
                    }, label: {
                        Text("Encrypt")
                    }).padding()
                    Button(action:{
                        self.isDecrypting = true
                        isImporting = true
                    }){
                        Text("Decrypt")
                    }.padding()
                }
                
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.data],
                allowsMultipleSelection: false,
                onCompletion:onFileImportingSelected)
            .fileExporter(
                isPresented: $isExporting,
                document: documentExportContent,
                contentType: documentExportType,
                defaultFilename: "file",
                onCompletion: onFileExported)
            .alert(isPresented: $isAlertShowing, content: {
                Alert(title: Text(alertTitle), message: Text(alertText), dismissButton: .default(
                    Text("OK"),
                    action: {
                        if self.isDecrypting || self.isEncrypting {
                            self.isExporting = true
                        }
                    }
                ))
            })
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FileEncryptionView()
        }
    }
}

extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
}

extension String {
    func GetUTType() -> UTType? {
        let ret = UTType.types(tag: self, tagClass: .filenameExtension, conformingTo: nil).first!
        return ret
    }
}

