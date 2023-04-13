//
//  DataManager.swift
//  CalculatorRecognition
//
//  Created by tamu on 13/04/23.
//

import Foundation

class DataManager {
    static let sharedInstance = DataManager()
    let defaultStandard = UserDefaults.standard

    func setKey(text: String) {
        defaultStandard.setValue(text, forKey: "key")
    }
        
    func getKey() -> String {
        return defaultStandard.value(forKey: "key") as? String ?? ""
    }
    
    func setIV(value: [UInt8]) {
        defaultStandard.setValue(value, forKey: "iv")
    }
    
    func getIV() -> [UInt8] {
        return defaultStandard.value(forKey: "iv") as? [UInt8] ?? [UInt8]()
    }
}
