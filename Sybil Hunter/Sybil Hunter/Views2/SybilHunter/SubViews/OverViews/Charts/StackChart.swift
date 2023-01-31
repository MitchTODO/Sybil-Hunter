//
//  StackChart.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/25/23.
//

import SwiftUI
import Charts

struct SybilChart: Identifiable {
    var id:String = "no"
    var name: String
    var quantity: Int
    var color:Color
}

struct StackChart: View {
    var frameHeight = 400.0
    @EnvironmentObject var sybilHunter:SybilHunterViewModel

    let sybil = SybilChart(
                            name:"Sybil" ,
                           quantity: 25,
                            color:.red
                   )
    let notSybil = SybilChart(name: "NonSybil",
                           quantity: -100,
                              color:.green
                   )
    

    
    var body: some View {
        Chart {
            
            BarMark(x: .value("sybil", sybilHunter.sybil  * -1 ) , y: .value("Quantity", sybil.id))
                .annotation(position: .leading) {
                    Text("\(abs(sybilHunter.sybil * -1 ))")
                        .font(.caption)
                    
                }.foregroundStyle(sybil.color)
            
            BarMark(x: .value("Month", (sybilHunter.nonSybil)) , y: .value("Quantity", notSybil.id))
                .annotation(position: .trailing ) {
                    Text("\(abs(sybilHunter.nonSybil ))")
                        .font(.caption)
                    
                }.foregroundStyle(notSybil.color)
                
        }
            
        .padding()
        .chartPlotStyle { plotArea in
            plotArea.frame(height: CGFloat(frameHeight * Double(1.0)) / 10 )
        }
        .chartForegroundStyleScale([
            "Sybil": .red, "NonSybil": .green
        ])
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(preset: .automatic,position: .top){ value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel() {
                    if let va = value.as(Int.self) {
                        if va < 0 {
                            
                            Text("\(abs(va))")
                            
                        }else{
                            Text("\(va)")
                        }
                    }
                }
            }
        }
    }
}

struct StackChart_Previews: PreviewProvider {
    static var previews: some View {
        StackChart()
    }
}
