//
//  AddressLists.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/22/23.
//

import SwiftUI

struct AddressLists: View {
    let address:String
    let source:DataSource
    
    @EnvironmentObject var sybilHunter:SybilHunterViewModel

    
    func genResults() -> Int {
        var score = 0
        if sybilHunter.addressResult[address] != nil {
            for lego in sybilHunter.addressResult[address]!.legoResult.keys {
                if sybilHunter.addressResult[address]!.legoResult[lego]! != 2 {
                    score += sybilHunter.addressResult[address]!.legoResult[lego]!
                }
            }
        }
        return score
    }
    
    func genCells(lego:Lego2) -> AnyView{
        if sybilHunter.addressResult[address] != nil {
            switch(sybilHunter.addressResult[address]!.legoState[lego.name]) {
            case .finished:
                return AnyView(
                    Circle()
                        .fill(lego.colorId)
                        .frame(width:10,height: 10)
                    //Text("Finsihed")
                )
            case .que:
                return AnyView(
                    Circle()
                        .stroke(lego.colorId)
                        .frame(width:10,height: 10)
                    //Text("Que")
                )
            case .failure:
                return AnyView(
                    Circle()
                        .fill(.red)
                        .frame(width:10,height: 10)
                    //Text("Failure")
                )
            case .processing:
                return AnyView(
                    ProgressView()
                        .tint(lego.colorId)
                        .progressViewStyle(CircularProgressViewStyle(tint: lego.colorId))
                        .accentColor(lego.colorId)
                        .scaleEffect(0.5)
                        //.frame(width:10,height: 10)
                    //Text("Processing")
                )

            case .none:
                return AnyView(Text("Unknown State"))
            }
        }else{
            return AnyView(Text(""))
        }
    }
    
    var body: some View {
        Button(action: {
            // write to clipboard
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(address, forType: .string)
        }, label: {
            HStack{
                
                Text(address).monospaced()
                ForEach(sybilHunter.selectedLegos,id:\.name) { lego in
                    genCells(lego: lego)
                }
                Text("Score \(genResults())")
            }
        }).buttonStyle(.borderless)

    }
}

