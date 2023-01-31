//
//  EthService.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/22/23.
//

import Foundation

// MARK: checkAddresses
/// Basic check for a string representing an Ethereum address
///
/// - Parameters:
///         - `addresses` : Array of strings representing Ethereum address
///
/// - Returns: Bool  if all strings match a ethereum address
///
func checkAddresses(addresses:[String]) -> Bool {
    for address in addresses {
        // Check if string has 42 chars and starts with 0x
        let ethMark = address.prefix(2) as Substring
        if address.count != 42 && ethMark != "0x" {
            return false
        }
        
    }
    return true
}

