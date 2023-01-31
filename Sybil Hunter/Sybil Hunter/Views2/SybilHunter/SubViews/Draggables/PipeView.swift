//
//  PipeView.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/20/23.
//

import SwiftUI

struct PipeView: View {
    
    @EnvironmentObject var sybilHunter:SybilHunterViewModel
    
    var source:DataSource
    
    var body: some View {

        VStack{
                Button(action: {
                   
                }, label: {
                    Text(source.name)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.callout)
                        .monospaced()
                })
                .buttonStyle(.borderedProminent)
                .tint(source.isEthAddress ? Color.blue: Color(.red))
                .foregroundColor(.white)
                .background(source.isEthAddress ? Color.blue: Color(.red))
                .clipShape(Capsule())
                .cornerRadius(10)
                
  
        }
    
        .contextMenu {

            Button(action: {
                sybilHunter.cleanResults()
                for (index,element) in sybilHunter.selectedDataSource.enumerated() {
                    if element.name == source.name {
                        
                        sybilHunter.dataSource.append(element.fileLocation)
                        sybilHunter.sourceResult.removeValue(forKey: element.name)
                        sybilHunter.selectedDataSource.remove(at: index)
                        sybilHunter.updateAddressCount()
                    }
                }
                
            }){
                Text("Remove")
            }.disabled(sybilHunter.isRunning)
        }
        
    }
}

