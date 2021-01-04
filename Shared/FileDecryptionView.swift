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

struct FileDecryptionView: View {
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    @State private var isDecrypting: Bool = false
    @State private var isAlertShowing: Bool = false
    @State private var alertText: String = ""
    @State private var alertTitle: String = ""
    @ObservedObject private var password = ZeroableString("")
    @State private var showPasswordError = false
    @State private var showPasswordOkey = false
    @State private var isLoading: Bool = false
    @State private var documentExportContent: AbemDocument? = nil
    @State private var documentExportType: UTType = UTType.data
    @State private var decryptDisabled = true
    
    func showModalMessage(body text:String, _ title:String = "") {
        self.alertTitle = title
        self.alertText = text
        self.isAlertShowing = true
    }
    
    func showModalError(_ text: String) {
        self.alertTitle = "Error"
        self.alertText = text
        // We cancel any possible decrypting process.
        self.isDecrypting = false
        // Show the alert dialog.
        self.isAlertShowing = true
    }
    
    func onTextPasswordChanged(_ newValue: String) {
        if newValue.count == 0 {
            self.decryptDisabled = true
        } else {
            self.decryptDisabled = false
        }
    }
    
    func onFileImportingSelected(result: Result<[URL], Error>)  {
        if case .failure(let failure) = result {
            showModalError(failure.localizedDescription)
            return
        }
        self.isLoading = true
        let selectedFiles = try! result.get()
        DispatchQueue.global(qos: .userInteractive).async {
            decryptFiles(selectedFiles: selectedFiles)
        }
        return
    }
    
    func onFileExported(result: Result<URL, Error>)  {
        let url = try! result.get()
        let filename = "\(url.lastPathComponent)"
        let text = "Decrypted file saved to: \(filename)"
        self.isDecrypting = false
        self.showModalMessage(body: text, "Action Finished")
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
            let title = "Finished"
            let text  = """
                The content of the file has been decrypted.
                Now you will we asked to move those contents to a file
                of your choice.
                """
            DispatchQueue.main.sync {
                password.zero(with: "0")
                password.val = ""
                self.documentExportContent = clearDocument
                self.documentExportType = ut!
                self.showModalMessage(body: text, title)
            }
            
        } catch Abem.AbemError.decryptError {
            let error = ViewError.LogicalError(description: "Error decrypting file")
            DispatchQueue.main.sync {
                showModalError(error.localizedDescription)
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
        LoadingView(isShowing: $isLoading, text:"Decrypting"){
            VStack(alignment:HorizontalAlignment.center) {
                Text("A8EM").font(.title).foregroundColor(.blue).background(Color.yellow).padding(.top, 10)
                Divider()
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                    SecureField("Password",text:$password.val)
                        .onChange(of: password.val, perform: onTextPasswordChanged)
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
                    Button(action:{
                        self.isDecrypting = true
                        isImporting = true
                    }){
                        Text("Decrypt")
                    }.padding().disabled(decryptDisabled)
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
                        if self.isDecrypting {
                            self.isExporting = true
                        }
                    }
                ))
            })
        }
    }
}


struct FileDecryptionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FileDecryptionView()
        }
    }
}

