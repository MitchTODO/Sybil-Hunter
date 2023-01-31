//
//  LegoEditView.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/22/23.
//

import SwiftUI

struct LegoEditView: View {
    
    @EnvironmentObject var sybilHunter:SybilHunterViewModel
    @State var editLego:Lego2
    
   

    var body: some View {
        VStack(alignment: .center){
            HStack{
                Button(action: {
                    sybilHunter.isEditingLego = false
                }, label: {
                    Image(systemName: "chevron.backward")
                }).buttonStyle(.borderless)
                    .padding(10)
                Spacer()
                Text("Edit Lego").font(.title).bold().monospaced()
                Spacer()
               
            }
            Text(sybilHunter.editLego!.name).font(.title2).bold()
            if sybilHunter.editLego!.isExternalScript {
                VStack(alignment: .leading) {
                    Text("Script Path").font(.headline).bold()
                    TextField("/..", text: $editLego.fullPath)
                    Text("Command").font(.headline).bold()
                    TextField("python3", text: $editLego.cmd)
                }

                Button(action: {
                    for (index,lego) in sybilHunter.selectedLegos.enumerated() {
                        if lego.name == editLego.name {
                            sybilHunter.selectedLegos[index] = editLego
                        }
                    }
                }, label: {
                    Text("Update").font(.headline).bold()
                }).buttonStyle(.borderedProminent)
            }

           
        }.padding(20)
        Spacer()
    }
}

