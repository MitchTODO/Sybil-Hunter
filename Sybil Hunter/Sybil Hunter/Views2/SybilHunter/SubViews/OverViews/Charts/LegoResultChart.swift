//
//  LegoResultChart.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/25/23.
//

import SwiftUI
import Charts

struct LegoChartData:Identifiable {
    var id: UUID = UUID()
    var name: String
    var sybil: [Sybil]
    var color: Color
}

struct Sybil:Identifiable {
    var id:UUID = UUID()
    var result:Int
    var name:String
}



struct LegoResultChart: View {
    
    @EnvironmentObject var sybilHunter:SybilHunterViewModel

    
    var body: some View {
        
        VStack{
            HStack{
                Spacer()
                Text("Overall Health").font(.title2).monospacedDigit().bold()
                Spacer()
            }
            HStack{
                Chart(sybilHunter.selectedLegos) { sel in
                    
                    BarMark(
                        x: .value("Count", sel.sybilResult.sybil),
                        y: .value("Source", "Sybil")
                    )
                    .foregroundStyle(sel.colorId)
                    .annotation(position:.overlay,alignment: .trailingFirstTextBaseline) {
                        Text("\(sel.sybilResult.sybil)")
                    }
       
                    BarMark(
                        x: .value("Count", sel.sybilResult.nonSybil),
                        y: .value("Source", "nonSybil")
                    )
                    .foregroundStyle(sel.colorId)
                    .annotation(position:.overlay,alignment: .trailingFirstTextBaseline) {
                        Text("\(sel.sybilResult.nonSybil)")
                    }
                }

                
                .padding(20)
                VStack{
                    Spacer()
                    Text(" \(sybilHunter.sybil)").font(.title3).monospacedDigit().bold()
                    Spacer()
                    Text(" \(sybilHunter.nonSybil)").font(.title3).monospacedDigit().bold()
                    Spacer()
                }.padding(10)
            }.frame(height: 200)

            
        }.background(.separator)
        .cornerRadius(20)
        .padding(20)
        
            
        
 

    }
}

struct LegoResultChart_Previews: PreviewProvider {
    static var previews: some View {
        LegoResultChart()
    }
}
