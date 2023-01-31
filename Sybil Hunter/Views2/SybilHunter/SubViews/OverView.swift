//
//  OverView.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/21/23.
//

import SwiftUI




struct OverView: View {

    
    @EnvironmentObject var sybilHunter:SybilHunterViewModel
    
    var body: some View {
        ScrollView{
            VStack{
                VStack{
                    LegoResultChart().environmentObject(sybilHunter)
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 20) {
                            ForEach(sybilHunter.selectedDataSource,id: \.name) { source in
                                RoundChart(source: source).environmentObject(sybilHunter)
                                   
                            }
                        }
                    }
                    
                }
                Spacer()
                InputView().environmentObject(sybilHunter)
                    .padding(20)
                    .frame(maxHeight:500 )
                
            }
        }


    }
}

struct OverView_Previews: PreviewProvider {
    static var previews: some View {
        OverView()
    }
}
