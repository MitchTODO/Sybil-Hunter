//
//  SybilHunter.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/20/23.
//

import SwiftUI


struct SybilHunter: View {
    
    @EnvironmentObject var sybilHunter:SybilHunterViewModel
    
    var body: some View {
        NavigationView{
            List {
                Section(header: DataSourceHeader().environmentObject(sybilHunter)) {
                    ForEach(sybilHunter.dataSource, id:\.self) { data in
                        VStack{
                            HStack{
                                DragView(file: data)
                            }
                        }.background(.separator)
                            .cornerRadius(5)
                            .onDrag{
                                NSItemProvider(object: String(data) as NSString)
                            }
                        
                    }
                }.collapsible(false)
                
                Section(header: LegoHeader().environmentObject(sybilHunter)) {
                    ForEach(sybilHunter.legos, id:\.self) { lego in
                        VStack{
                            HStack{
                                DragView(file: lego )
                            }
                        }.background(.separator)
                            .cornerRadius(5)
                            .onDrag{
                                NSItemProvider(object: String(lego) as NSString)
                            }
                        
                        
                    }
                }.collapsible(false)
                
            }
            .listStyle(.automatic)
            
            NavigationStack {
                NavigationView {
                    PipelineView().environmentObject(sybilHunter)
                    if sybilHunter.isEditingLego == true {
                        LegoEditView(editLego:sybilHunter.editLego!).environmentObject(sybilHunter)
                    }
                    else{
                        OverView().environmentObject(sybilHunter)
                    }
                }
                
                HStack{
                    Text("Finished Subprocess \(sybilHunter.addressCount * sybilHunter.selectedLegos.count) : \(sybilHunter.completedRequest)").font(.caption)
                    Spacer()
                } .padding(5)
                    .background(.blue)
            }
        }.navigationTitle("")
    }
}

struct SybilHunter_Previews: PreviewProvider {
    static var previews: some View {
        SybilHunter()
    }
}
