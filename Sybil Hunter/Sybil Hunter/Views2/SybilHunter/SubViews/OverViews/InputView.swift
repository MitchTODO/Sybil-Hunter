//
//  InputView.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/22/23.
//

import SwiftUI

struct InputView: View {
    @EnvironmentObject var sybilHunter:SybilHunterViewModel
    @State var hoverOn = false
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text("Total Addresses \(sybilHunter.addressCount)").font(.title2)
                    .bold()
                Spacer()
                HStack {
                    Picker("Number of concurrent processes", selection: $sybilHunter.processLimit) {
                        ForEach(1...5, id: \.self) {
                            Text("\($0)")
                        }
                    }.frame(width: 260)
                    .pickerStyle(.menu)
                    .disabled(sybilHunter.isRunning)
                }
                Text("Total Subprocess \(sybilHunter.addressCount * sybilHunter.selectedLegos.count)").font(.title2)
                    .bold()
            }


        ScrollView {
            LazyVStack(spacing:10,pinnedViews: [.sectionHeaders]) {

                ForEach(sybilHunter.selectedDataSource, id: \.name) { source in
                    Section(header: HStack {
                        Text("\(source.name)")
                            .font(.title3)
                            .bold()
                            .padding(10)
                      Spacer()
                      
                    }){
                        ForEach(source.addresses,id:\.self) { address in
                                AddressLists(address:address,source:source).environmentObject(sybilHunter)
                            
                        }
                    }.listStyle(.plain)
                    
     
                }
            }.padding(10)
        }.background(.separator)
            
            .cornerRadius(20)
        }
    }
    
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
    }
}
