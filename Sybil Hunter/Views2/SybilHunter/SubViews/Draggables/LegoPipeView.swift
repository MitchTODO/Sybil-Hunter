//
//  LegoPipeView.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/21/23.
//

import SwiftUI

struct LegoPipeView: View {
    
    @EnvironmentObject var sybilHunter:SybilHunterViewModel
    var lego:Lego2
    var errorReading = false
    
    var body: some View {
        
        VStack{
            Button(action: {
                sybilHunter.editLego = lego
                sybilHunter.isEditingLego = true
            }, label: {
                Text(lego.name)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .font(.callout)
                    .monospaced()
            })
            .buttonStyle(.borderedProminent)
            .tint(lego.colorId)
            .foregroundColor(.white)
            .background(lego.colorId)
            .clipShape(Capsule())
            .cornerRadius(10)
               
            
        }

        //.cornerRadius(10)
        
        //
        //
        
        
        .contextMenu {
            
            Button(action: {
                    sybilHunter.cleanResults()
                    for (index,element) in sybilHunter.selectedLegos.enumerated() {
                        if element.name == lego.name {
                            
                            sybilHunter.legos.append(element.name)
                            sybilHunter.selectedLegos.remove(at: index)
                            sybilHunter.updateAddressCount()
                        }
                    }
            }){
                Text("Remove")
            }.disabled(sybilHunter.isRunning)
        }

    }
}

struct LegoPipeView_Previews: PreviewProvider {
    static var previews: some View {
        LegoPipeView(lego: Lego2(isExternalScript: false,cmd:"", parameters: "", name: "Name",fullPath: ""))
    }
}
