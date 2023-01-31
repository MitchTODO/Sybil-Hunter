//
//  DragView.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/20/23.
//

import SwiftUI

struct DragView: View {
    
    private var lastPath:String = ""
    
    init(file:String) {
        let name = URL(string: file)
        if name == nil {
            lastPath = file
        }else{
            lastPath = name!.lastPathComponent.description
        }
        
    }
    
    var body: some View {
    
                Text(lastPath)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 10)
                    .font(.headline)
                    .bold()
                    .padding()
        
                    

    }
}

