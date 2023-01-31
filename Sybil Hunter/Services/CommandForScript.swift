//
//  CommandForScript.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/22/23.
//

import Foundation

// MARK: commandForScript
/// Matches language to matching cmd
///
/// - Parameters:
///         - `cmd` : language identifier 
///
/// - Returns: String path of the appropriate cmd
///
func commandForScript(cmd:String) -> String {
    switch(cmd) {
        case "py":
            return "/Applications/Xcode.app/Contents/Developer/usr/bin/python3"
        default:
            return "Language not detect please set the command."

    }

}
