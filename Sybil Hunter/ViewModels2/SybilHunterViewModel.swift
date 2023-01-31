//
//  SybilHunterViewModel.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/20/23.
//

import Foundation
import SwiftUI


enum AddressStates {
    case finished
    case processing
    case que
    case failure
}

struct LegoSybil {
    var sybil = 0
    var nonSybil = 0
}
// Lego2 struct
// How a lego should be run 
struct Lego2:Identifiable {
    var id:UUID = UUID()
    var isExternalScript:Bool
    var cmd:String
    var parameters:String
    var name:String
    var fullPath:String
    var sybilResult = LegoSybil()
    var colorId:Color = .random
}

// Data source struck
struct DataSource {
    var name:String
    var fileLocation:String
    var splitId = "\n"
    var isEthAddress:Bool
    var addresses:[String] = []
}


struct AddressResults {
    var legoState:[String:AddressStates] = [:]
    var legoResult:[String:Int] = [:]
}

struct TaskSyn {
    var lego:Lego2
    var address:String
}

// MARK: SybilHunterViewModel
///
/// Input pipeline
/// Handles processors
/// Lego results
///
class SybilHunterViewModel:ObservableObject {
    // legos arrays
    @Published var legos:[String] = []
    @Published var selectedLegos:[Lego2] = []
    
    // dataSource arrays
    @Published var dataSource:[String] = []
    @Published var selectedDataSource:[DataSource] = []
    
    // Processing variables
    @Published var isRunning = false
    @Published var isWaiting = false
    @Published var addressCount = 0
    @Published var completedRequest = 0
    
    // Results from legos
    // Map address to sybil results
    @Published var addressResult:[String:AddressResults] = [:]
    @Published var sourceResult:[String:LegoSybil] = [:]
    @Published var sybil = 0
    @Published var nonSybil = 0
    
    // Lego Editing
    @Published var editLego:Lego2? = nil
    @Published var isEditingLego = false
    
    // Processing settings and Ques
    @Published var processLimit = 2
    
    var queProcess:[LegoProcess] = []
    
    
    // Updates amount of address from each group
    func updateAddressCount() {
        var total = 0
        for group in selectedDataSource{
            if group.isEthAddress {
                total += group.addresses.count
            }
        }
        addressCount = total
    }
    
    
    // Checks if key for result exist
    func resultsExist() -> Bool {
        return addressResult.keys.count == 0
    }
    
    
    func canStart() -> Bool {
        if (selectedLegos.isEmpty || selectedDataSource.isEmpty) {
            return false
        }
        if (!isRunning && isWaiting) {
            return false
        }
        return true
    }
    
    func canClear() -> Bool {
        if (!isRunning && !isWaiting) {
            return true
        }
        
        return false
    }
    
    
    // Cleans out dictionary results
    func cleanResults() {
        sybil = 0
        nonSybil = 0
        completedRequest = 0
        addressResult.removeAll()
        
        for keys in sourceResult.keys {
            sourceResult[keys]!.nonSybil = 0
            sourceResult[keys]!.sybil = 0
        }
        for (index, _ ) in selectedLegos.enumerated() {
            selectedLegos[index].sybilResult = LegoSybil()
        }
    }
    
    
    // MARK: checkResults
    ///
    /// Sets result from a lego into the apporate variables
    ///
    /// - Parameters
    ///             `dataSource` : String name of dataSource
    ///             `forAddress`:Sting ethereum address
    ///             `lego`:Sting name of lego
    ///             `result`: Int of lego result (Int representing bool)
    ///
    ///
    func checkResults(dataSource:String,forAddress:String,lego:String,result:Int) {
        // Set result in dict for data source and overall health
        //if result == 0 {
        //    sourceResult[dataSource]!.nonSybil += 1
        //    nonSybil += 1
        
        //}
        //else{
        //    sourceResult[dataSource]!.sybil += 1
        //    sybil += 1
        //}
        
        // sets individual address results and update address state
        if addressResult[forAddress] == nil {return}
        addressResult[forAddress]!.legoResult[lego] = result
        completedRequest += 1
        
        if self.addressResult[forAddress]!.legoState[lego]! != .failure {
            self.addressResult[forAddress]!.legoState[lego]! = .finished
            self.addressResult[forAddress]!.legoResult[lego]! = result
            
            
            var isFinished = true
            for result in  self.addressResult[forAddress]!.legoResult.values {
                if result == 2 {
                    isFinished = false
                }
            }
            
            if isFinished {
                
                var finalResult = 0
                for result in self.addressResult[forAddress]!.legoResult.values {
                    finalResult += result
                }
                // If total values exceed half the lego amount consider sybil
                if finalResult > selectedLegos.count / 2 {
                    sourceResult[dataSource]!.sybil += 1
                    sybil += 1
                }else{
                    sourceResult[dataSource]!.nonSybil += 1
                    nonSybil += 1
                }
                
                
                for (index,_) in selectedLegos.enumerated() {
                    if selectedLegos[index].name == lego {
                        if finalResult > selectedLegos.count / 2 {
                            selectedLegos[index].sybilResult.sybil += 1
                        }else {
                            selectedLegos[index].sybilResult.nonSybil += 1
                            
                        }
                        
                    }
                }
            }
        }
        
        
        // Check if all subprocess are finished
        if addressCount * selectedLegos.count <= completedRequest {
            isRunning = false
            isWaiting = false
        }
        
    }
    
    
    // MARK: start
    ///
    /// Start running subprocess for all address and lego
    ///
    func start() {
        // Loop through each file
        for data in selectedDataSource {
            // Loop through each lego
            for address in data.addresses  {
                // for each lego run the address
                for lego in selectedLegos {
                    if addressResult[address] == nil {
                        var legoResult:[String:Int] = [:]
                        var legoState:[String:AddressStates] = [:]
                        for l in selectedLegos {
                            
                            // init lego state with que
                            legoResult[l.name] = 2 // unkown
                            legoState[l.name] = .que
                        }
                        // create and set new address result
                        addressResult[address] = AddressResults(legoState:legoState, legoResult: legoResult)
                    }else{
                        // Update address result
                        if addressResult[address]!.legoResult[lego.name] == nil {
                            addressResult[address]!.legoResult[lego.name] = 2
                            addressResult[address]!.legoState[lego.name] = .que
                        }
                    }
                    // Only using external scripts
                    if lego.isExternalScript{
                        // Check if result exist
                        if addressResult[address]!.legoState[lego.name] == .que {
                            // run safeshell
                            callSafeShall(lego:lego, address: address) { result in
                                
                                switch(result){
                                case .success(let isSybil):
                                    DispatchQueue.main.async {
                                        self.checkResults(dataSource:data.name,forAddress: address, lego: lego.name, result: isSybil)
                                        
                                    }
                                case .failure(let error):
                                    DispatchQueue.main.async {
                                        self.addressResult[address]!.legoState[lego.name] = .failure
                                        
                                    }
                                }
                                
                            }
                        }else{
                            
                            // Results exists update completed requests
                            completedRequest += 1
                      
                            if addressCount * selectedLegos.count <= completedRequest {
                                isRunning = false
                                isWaiting = false
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: callSafeShall
    ///
    /// Appends a new preocess to the que & calls check que
    ///
    /// - Parameters
    ///             `lego` : Lego2 struct of lego to run
    ///             `address`:Sting ethereum address used for lego input
    ///
    ///
    func callSafeShall(lego:Lego2,address:String, completion:@escaping(Result<Int,Error>) -> Void ) {
        let lp = LegoProcess(lego: lego, address: address,comp: completion)
        queProcess.append(lp)
        checkQue()
    }
    
    
    // MARK: callSafeShall
    ///
    /// Manages and runs qued subprocesses
    ///
    func checkQue() {
        // Get amount of running tasks
        var runningTaskCount = 0
        for process in queProcess {
            if process.state == .running {
                runningTaskCount += 1
            }
        }
        
        // Remove all que processes if stopped and no current running task
        // allows for running tasks to finish
        if self.isWaiting {
            if runningTaskCount == 0 {
                queProcess.removeAll()
                DispatchQueue.main.async {
                    self.isRunning = false
                    self.isWaiting = false
                }
            }
            return
        }
        
        // Run a qued process until process limit is met
        for p in queProcess {
            if runningTaskCount < processLimit {
                if p.state == .suspended {
                    runningTaskCount += 1
                    // update address result state
                    DispatchQueue.main.async {
                        self.addressResult[p.address]!.legoState[p.lego.name] = .processing
                        
                    }
                    // run qued process
                    p.run() { res in
                        // recursive until all qued processing have been met
                        self.checkQue()
                    }
                }
            }else{
                // return if processLimit is met
                return
            }
        }
    }
    
}
