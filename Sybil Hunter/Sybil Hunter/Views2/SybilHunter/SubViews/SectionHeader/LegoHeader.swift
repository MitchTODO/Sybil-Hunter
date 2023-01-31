//
//  LegoHeader.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/20/23.
//

import SwiftUI

struct LegoHeader: View {
    @EnvironmentObject var sybilHunter:SybilHunterViewModel
    
    var body: some View {
        HStack{
            Text("Legos")
            Spacer()
            Button {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = true
                panel.canChooseFiles = false
                let directoryPath = panel.url?.lastPathComponent ?? ""
                if panel.runModal() == .OK {
                    var legos:[String] = []
                    let fm = FileManager.default
                    do {
                        let legoFile = try fm.contentsOfDirectory(at: panel.url!, includingPropertiesForKeys: nil)
                        // process files
                        for (index,lego) in legoFile.enumerated() {
                            let legoName = lego.lastPathComponent
                            // Dont load hidden files in legos directory
                            if !legoName.starts(with: ".") {
                                //let newLego = DataSource(name: legoName, type: .legos, fileLocation: lego.absoluteString, data: [])
                                legos.append(lego.absoluteString)
                            }

                        }
                    } catch {
                        print("Error while enumerating files \(panel.url!.path): \(error.localizedDescription)")
                    }
                    sybilHunter.legos.append(contentsOf: legos)
                }
            } label: {
                Image(systemName: "plus")
            }.buttonStyle(.borderless)
                .padding(5)
        }
    }
}

struct LegoHeader_Previews: PreviewProvider {
    static var previews: some View {
        LegoHeader()
    }
}
