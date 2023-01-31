//
//  AssociationClassifierLego.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/22/23.
//

import Foundation

enum InternalLego {
    case associationClassifier
    case associationRegressor
}

struct ConsolidedTx {
    var ins:Int = 0
    var outs:Int = 0
    var outAmount:Double = 0.0
    var inAmount:Double = 0.0
    var lastTimeStamp:Int = 0
    var timeBetween:Int = 0
    var isContract:Int = 0
    var topics:[String:Double] = [:]
    
}

// MARK: BuiltInLego
/// Runs a builtin lego
///
/// NOTE: Currently not used
///

class BuiltInLego {
    static let shared = BuiltInLego()
    // Amount of active DataTask
    private var activeQueueCount = 5
    private var TBQueue:[URLSessionDataTask] = []
    
    private let weiToEth = Double(pow(Double(10),Double(18)))
    
    // MARK: callLego
    /// Switch between internal lego and calls
    ///
    /// - Parameters
    ///             `name` :name of built In lego
    ///             `input`:Input tx data for built in lego
    ///
    /// - Returns Int : Lego output result
    ///
    func callLego(name:String,input:[String:ConsolidedTx]) -> Int  {
        switch(name){
        case "Classifier v1.0":
            return (associationClassifier(input: input))
        case "Regressor v1.0":
            return (associationRegressor(input: input))
        default:
            return 3
        }
    }
    
    
    // MARK: txProcessor
    /// Processes tx data into a consolided tx based on address
    ///
    /// - Parameters
    ///             `txData` : TrueBlocks data result
    ///             `addressFor`:String representing ethereum address
    ///
    /// - Returns [String:ConsolidedTx] :  Processed  consolided  tx data
    ///
    func txProcessor(txData:Welcome,addressFor:String) -> [String:ConsolidedTx] {
        var addressCounts:[String:ConsolidedTx] = [:]
        for tx in txData.data {
            var contactAddress = ""
            var inAmount = 0.0
            var outAmount = 0.0
            var ins = 0
            var outs = 0
            if addressFor == tx.to {
                contactAddress = tx.from
                inAmount = tx.value
                ins = 1
                
            }else{
                contactAddress = tx.to
                outAmount = tx.value
                outs = 1
            }
            if !addressCounts.keys.contains(contactAddress) {
                addressCounts[contactAddress] = ConsolidedTx()
            }
            addressCounts[contactAddress]!.outs += outs
            addressCounts[contactAddress]!.ins += ins
            addressCounts[contactAddress]!.inAmount += inAmount
            addressCounts[contactAddress]!.outAmount += outAmount
            
            
            let difference = tx.timestamp - addressCounts[contactAddress]!.lastTimeStamp
            if addressCounts[contactAddress]!.lastTimeStamp != 0 {
                addressCounts[contactAddress]!.timeBetween =  (difference + addressCounts[contactAddress]!.timeBetween) / 2
                
            }
            addressCounts[contactAddress]!.lastTimeStamp = tx.timestamp
            
            if txData.meta.namedTo.keys.contains(contactAddress) {
                let isContract = txData.meta.namedTo[contactAddress]!.isContract
                if isContract {
                    addressCounts[contactAddress]!.isContract = 1
                }
            }
            
            for log in tx.receipt.logs{
                for topic in log.topics {
                    if !addressCounts[contactAddress]!.topics.keys.contains(topic) {
                        addressCounts[contactAddress]!.topics[topic] = 0
                    }
                    addressCounts[contactAddress]!.topics[topic]! += 1
                }

            }
        }
        for (key,values) in addressCounts {
            
            if values.inAmount != 0 {
                let inEth = values.inAmount / Double(weiToEth)
                addressCounts[key]!.inAmount = Double(String(format:"%.3f",inEth))!
            }
            if values.outAmount != 0 {
                let outEth = values.outAmount / Double(weiToEth)
                addressCounts[key]!.outAmount = Double(String(format:"%.3f",outEth))!
            }
        }
  
        return(addressCounts)
    }
    
    
    // MARK: fetchTxData
    /// Fetches tx data from trueblocks url
    ///
    /// - Parameters `address` : wallet address to get tx data from TrueBlocks Url
    /// - Returns completion: <TrueBlocksData:Error>
    func fetchTxData(address:String, completion:@escaping(Result<Welcome,Error>) -> Void) {
        // Get user default trueblock url
        let defaults = UserDefaults.standard
        let trueBlocksUrl = defaults.string(forKey: "trueBlocksUrl") ?? ""
        // Build url with path and parameters
        var url = URL(string: trueBlocksUrl)!
        url.append(component: "export")
        let queryItems = [URLQueryItem(name: "addrs", value: address), URLQueryItem(name: "maxRecords", value: "10")]
        url.append(queryItems: queryItems)
        // Create url session task
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let jsonDecoder = JSONDecoder()
            self.reOrderQueue()
            do {
                let txData = try jsonDecoder.decode(Welcome.self, from: data)
                completion(.success(txData))
            } catch {
                completion(.failure(error))
            }
            
        }
        
        // Append task to queue
        TBQueue.append(task)
        // check firing order for task
        self.reOrderQueue()
    }
    
    // MARK: reOrderQueue
    /// Called when a task is added or completed
    /// Prohibits over utilization of network resources
    private func reOrderQueue() {
        var runningTaskCount = 0
        for element in TBQueue {
            if element.state == .running {
                runningTaskCount += 1
            }
        }
        for tas in TBQueue {
            if runningTaskCount < activeQueueCount {
                if tas.state == .suspended {
                    tas.resume()
                    runningTaskCount += 1
                }
            }else{
                return
            }
        }
        
    }
    
}

