//
//  ContentView.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/13/23.
//

import SwiftUI

struct ContentView: View {
    
    enum Views {
        case roundHealth
        case sybil
    }
    @State private var selectedView:Views = .sybil
    
    
    @ObservedObject var sybilHunterVM = SybilHunterViewModel()
    
    private func toggleSidebar() { // 2
    #if os(iOS)
    #else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    #endif
    }
    

    
    var body: some View {
        
        VStack{
            SybilHunter().environmentObject(sybilHunterVM)
        }
            .toolbar {
                if selectedView == .sybil {
                    ToolbarItem(placement: .navigation) {
                        Button(action: toggleSidebar, label: {
                            Image(systemName: "sidebar.leading")
                        })
                    }
                    
                    
                    
                    ToolbarItem(placement: .primaryAction){
         
                        
                        Button(action: {
                            if sybilHunterVM.isRunning {
                                sybilHunterVM.isWaiting = true
                                
                            }else{
                                sybilHunterVM.isRunning = true
                                sybilHunterVM.isWaiting = false
                                sybilHunterVM.start()
                                sybilHunterVM.completedRequest = 0
                            }
                        }, label: {
                            if sybilHunterVM.isWaiting {
                                ProgressView().scaleEffect(0.5)
                            }
                            if sybilHunterVM.isRunning {
                                Label("Stop", systemImage: "pause.fill")
                                    .labelStyle(.titleAndIcon)
                                
                            }else{
                                Label("Run", systemImage: "play.fill")
                                    .labelStyle(.titleAndIcon)
                                    
                            }

                            
                        }).disabled(!sybilHunterVM.canStart() )
                        
                    }
                    
                    ToolbarItem(placement: .primaryAction){
                        Button(action: {
                            sybilHunterVM.cleanResults()
                        }, label: {
                            Label("Clear", systemImage: "xmark")
                                .labelStyle(.titleAndIcon)

                        }).disabled(!sybilHunterVM.canClear())
                        
                    }
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
