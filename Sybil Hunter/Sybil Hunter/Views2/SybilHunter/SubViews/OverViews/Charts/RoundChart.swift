//
//  roundChart.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/28/23.
//

import SwiftUI
import Charts

struct RoundChart: View {
    @EnvironmentObject var sybilHunter:SybilHunterViewModel
    var source:DataSource
    
    var body: some View {
        VStack{
            Text("\(source.name)")
                .font(.headline)
                .padding()
                .bold()
                .monospacedDigit()
            if source.isEthAddress {
                
                if sybilHunter.sourceResult[source.name] != nil {
                    Chart() {
                        BarMark(x:.value("Sybil", "Sybil") , y:   .value("Sybil", sybilHunter.sourceResult[source.name]!.sybil),width: .fixed(60.0))
                            .foregroundStyle(.red)
                            .position(by: .value("Name", "Sybil"))
                            .annotation(position:.overlay,alignment: .top) {
                                Text("\(sybilHunter.sourceResult[source.name]!.sybil)").bold()
                            }
                        BarMark(x: .value("NonSybil", "NonSybil")  , y:   .value("NonSybil", sybilHunter.sourceResult[source.name]!.nonSybil),width: .fixed(60.0))
                            .foregroundStyle(.green)
                            .position(by: .value("Name", "NonSybil"))
                            .annotation(position:.overlay,alignment: .top) {
                                Text("\(sybilHunter.sourceResult[source.name]!.nonSybil)").bold()
                            }
         
                        
                        
                    }.padding()
                    .frame(width:260)
                    
                }
            }else{
                Text("No Ethereum Addresses found, check file").bold()
            }
            

        }.background(.separator)
            .cornerRadius(5)
            .padding(20)
            
            
        


        
        
    }
         
}


