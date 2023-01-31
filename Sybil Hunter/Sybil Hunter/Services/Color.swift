//
//  Color.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/22/23.
//

import Foundation
import SwiftUI


extension Color {
    // Generate random color
    static var random: Color {
        
        return(Color(red: .random(in: 0...0.7),
                     green: .random(in: 0...0.7),
                     blue: .random(in: 0...0.7),
              opacity: 1.0)
            )

    }
}


