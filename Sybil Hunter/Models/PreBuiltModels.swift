//
//  PreBuiltModels.swift
//  Sybil Hunter
//
//  Created by mitchell tucker on 1/21/23.
//

import Foundation


let classifierlLego = Lego2(isExternalScript: false, cmd:"", parameters: "", name: "Classifier v1.0", fullPath: "")
let regressorlLego = Lego2(isExternalScript: false, cmd:"", parameters: "", name: "Regressor v1.0", fullPath: "")

let classifierlModel = AssociationClassifier()
let regressorModel = AssociationRegressor()


func associationClassifier(input:[String:ConsolidedTx]) -> Int {
    
    var notSybil = 0
    var sybil = 0
    
    for tx in input{
        guard let output = try? classifierlModel.prediction(address: tx.key, ins: Double(tx.value.ins), outs: Double(tx.value.outs), inAmount: tx.value.inAmount, outAmount: tx.value.outAmount, timeBetween: tx.value.topics, topics: Double(tx.value.timeBetween), isContract: Double(tx.value.isContract)) else {
            
            print("failed to predicted TX")
            return 0
        }
        
        if Int(output.sybil) == 1{
            sybil += 1
        }else{
            notSybil += 1
        }
    }
    if sybil > notSybil {
        return 1
    }else{
        return 0
    }
}

func associationRegressor(input:[String:ConsolidedTx]) -> Int {
    
    var notSybil = 0
    var sybil = 0
    
    for tx in input{
        guard let output = try? regressorModel.prediction(ins: Double(tx.value.ins), outs: Double(tx.value.outs), inAmount: tx.value.inAmount, outAmount: tx.value.outAmount, timeBetween: tx.value.topics, topics:  Double(tx.value.timeBetween))else{
                print("failed to predicted TX")
                return 0
            }
        
        if Int(output.sybil) == 1{
            sybil += 1
        }else{
            notSybil += 1
        }
    }
    if sybil > notSybil {
        return 1
    }else{
        return 0
    }

}



let prebuildLegos = [
    classifierlLego.name:classifierlLego,
    regressorlLego.name:regressorlLego
                     ]
