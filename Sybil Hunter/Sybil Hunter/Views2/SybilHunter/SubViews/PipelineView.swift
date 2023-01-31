//
//  PipelineView.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/20/23.
//

import SwiftUI
import UniformTypeIdentifiers


struct PipelineView: View,DropDelegate {
    
    @EnvironmentObject var sybilHunter:SybilHunterViewModel
    
    
    
    var body: some View {
        
        VStack {
            Text("Pipeline")
                .font(.title2)
                .padding(20)
            
            Section(header:Text("Input Address")) {
                List {
                    ForEach(sybilHunter.selectedDataSource, id:\.name) { data in
                        PipeView(source:data)
                            .environmentObject(sybilHunter)
                    }
                }
                    .cornerRadius(5)
                    .frame(height:300)
                    .padding(5)
                    .onDrop(of: [UTType.text], delegate: self)
            }
            
            Section(header:Text("Selected Legos")) {
                List {
                    ForEach(sybilHunter.selectedLegos, id:\.id) { lego in
                        LegoPipeView(lego:lego).environmentObject(sybilHunter)
                        
                    }
                }
                    .cornerRadius(5)
                    .padding(5)
                    .onDrop(of: [UTType.text], delegate: self)
            }
        }
    }
    
    // MARK: performDrop
    /// Calcuates total wait time for annouced rides
    /// - Note: Each driver gets 30 seconds to accept a ride.
    ///
    /// - Parameters :
    ///                 - `numberOfDrivers` : Integer - number of drivers
    ///
    func performDrop(info: DropInfo) -> Bool {
        if sybilHunter.isRunning {return(false)}
        sybilHunter.cleanResults()
        if let item = info.itemProviders(for: ["public.utf8-plain-text"]).first
        {
            item.loadItem(forTypeIdentifier: "public.utf8-plain-text") {
                (data, error) in
                if let data = data as? Data {
                    
                    let dropItem = NSString(data:data,encoding: 4)! as String
                    
                    if sybilHunter.dataSource.contains(dropItem) {
                        for (index,element) in sybilHunter.dataSource.enumerated() {
                            if element == dropItem {
  
                                
                                DispatchQueue.main.async { [self] in
                                    do {
                                      
                                        
                                        let fileUrl = URL(string: element)!
                                        let lastPath = fileUrl.lastPathComponent.description
                                        let fileContent = try String(contentsOf: fileUrl,encoding: .utf8)
                                        let walletAddress = fileContent.components(separatedBy: "\n")
                                        //let walletAddress = getAddressesFromFile(content:fileContent)
                                        // Check if imported eth wallets are correct
                                        let areAddress = checkAddresses(addresses: walletAddress)
                                        if sybilHunter.selectedDataSource.contains(where: {$0.name == lastPath}) {
                                            return
                                        }
                                        // Create new DataSource struct
                                        var newDataSource = DataSource(name: lastPath, fileLocation: element, isEthAddress: areAddress)
                                        
                                        if areAddress {
                                            
                                            newDataSource.addresses.append(contentsOf: walletAddress)
                                        }
                                        
                                        sybilHunter.selectedDataSource.append(newDataSource)
                                        sybilHunter.sourceResult[newDataSource.name] = LegoSybil()
                                        sybilHunter.updateAddressCount()
                                        sybilHunter.dataSource.remove(at: index)
                                        
                                    } catch {
                                        print("Error failed to read data from address txt file")
                                    }

                                    
                                }
                                
                            }
                        }
                    }
                    
                    if sybilHunter.legos.contains(dropItem) {
                        
                        for (index,element) in sybilHunter.legos.enumerated() {
                            if element == dropItem {
                                DispatchQueue.main.async { [self] in
                                    sybilHunter.legos.remove(at: index)
                                    // check if lego is prebuilt
                                    if prebuildLegos.keys.contains(element) {
                                        sybilHunter.selectedLegos.append(prebuildLegos[element]!)
                                    }else{
                                        let url = URL(string: element)!
                                       
                                        let newLego = Lego2(isExternalScript: true,cmd:  commandForScript(cmd: url.pathExtension),parameters: "", name:url.lastPathComponent.description, fullPath: element)
                                        sybilHunter.selectedLegos.append(newLego)
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                    
                    
                }
            }
        }
        return true
    }
}

struct PipelineView_Previews: PreviewProvider {
    static var previews: some View {
        PipelineView()
    }
}
