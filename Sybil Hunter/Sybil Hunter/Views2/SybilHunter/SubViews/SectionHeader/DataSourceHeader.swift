//
//  DataSourceHeader.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/20/23.
//

import SwiftUI

struct DataSourceHeader: View {
    @EnvironmentObject var sybilHunter:SybilHunterViewModel
    
    init() {
        
    }
    
    var body: some View {
        HStack{
            Text("Data Source")
            Spacer()
            Button {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = true
                panel.canChooseFiles = false
                panel.allowedContentTypes = [.plainText]
                let directoryPath = panel.url?.lastPathComponent ?? ""
                if panel.runModal() == .OK {
                    var dataSource:[String] = []
                    let fm = FileManager.default
                    do {
                        let sourceFile = try fm.contentsOfDirectory(at: panel.url!,includingPropertiesForKeys: nil)
                        for source in sourceFile {
                            let sourceName = source.lastPathComponent
                            // Dont load hidden files in legos directory
                            if !sourceName.starts(with: ".") {
                                
                                if !sybilHunter.dataSource.contains(where: {$0 == source.absoluteString}) {
                                    dataSource.append(source.absoluteString)
                                }
                                
                            }

                        }
                    } catch {
                        print("Failed to import direcotry")
                    }
                    sybilHunter.dataSource.append(contentsOf: dataSource)
   
                    //sybilHunter.dataSource.append(panel.url!.absoluteString)
                    
                    /*
                    let fm = FileManager.default
                    do {
                        let fileContent = try String(contentsOf: panel.url!,encoding: .utf8)
                        
                        let walletAddress = fileContent.components(separatedBy: "\n")
                        
                        //let newDataSource = DataSource(name:fileName,type:.address,fileLocation: panel.url!.absoluteString,data: walletAddress)
                        
                        
                       
                    } catch {
                        print("Error failed to read data from address txt file")
                    }
                    */
                }
            } label: {
                Image(systemName: "plus")
            }.buttonStyle(.borderless)
                .padding(5)
        }
    }
}

struct DataSourceHeader_Previews: PreviewProvider {
    static var previews: some View {
        DataSourceHeader()
    }
}
