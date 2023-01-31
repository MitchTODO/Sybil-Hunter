//
//  ScriptLegos.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/24/23.
//

import Foundation
import SwiftUI


// MARK: LegoProcess
/// Runs a lego script
///
class LegoProcess {
    
    // Process states
    enum State {
        case running
        case suspended
        case finished
    }
    
    // lego data and input
    let lego:Lego2
    let address:String
    
    var process:Process
    var pipe:Pipe
    
    let completion: (Result<Int, Error>) -> Void
    var state:State = .suspended
    
    
    // MARK: init
    ///
    /// Set up processor and pipe set with input data
    ///
    /// - Parameters
    ///             `lego` :Lego2 struct
    ///             `address`:Sting ethereum address for lego input
    ///
    ///
    init(lego: Lego2,address:String,comp:@escaping (Result<Int, Error>) -> Void) {
        // Set class variables
        self.completion = comp // set class call back for result
        self.lego = lego
        self.address = address
        // Create process and pipe
        self.process = Process()
        self.pipe = Pipe()
        
        // File url path of the lego script to run
        let url = URL(string: self.lego.fullPath)
        
        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)
        // Connect pipe to process
        self.process.standardOutput = pipe
        self.process.standardError = pipe
        // Set process launch path to lego command to run
        self.process.launchPath = lego.cmd
        // Set file url path and eth address arguments
        self.process.arguments = [components!.path, self.address]
        self.process.standardInput = nil
        
    }
    
    // MARK: run
    ///
    /// Runs process and completes the call back
    ///
    /// Note: Occasionally crashes do to failure in memory allocation when running process, seems to be caused by a excessive amount of subprocess task happening too fast. Do try does NOT catch this error and Will Crach the app.
    ///
    ///
    ///
    func run(comp:@escaping (Result<Int, Error>) -> Void) {
        // Change state
        state = .running
        // Wait between process helps memory allocation problems (Not a solution)
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            do{
                // Can crash do to memory allocation
                try self.process.run()
            }catch{
                self.completion(.failure(error))
                comp(.failure(error))
            }
        }
        
        DispatchQueue.global().async {
                // Return pipe result back to completion async
                let data = self.pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8)!
                let outputInt = (output as NSString).integerValue
                self.state = .finished
                self.process.terminate()
                self.completion(.success(outputInt))
                comp(.success(outputInt)) // complete with output
           
        }
    }
}
