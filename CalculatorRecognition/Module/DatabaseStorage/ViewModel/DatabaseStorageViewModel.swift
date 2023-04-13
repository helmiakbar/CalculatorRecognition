//
//  DatabaseStorageViewModel.swift
//  CalculatorRecognition
//
//  Created by tamu on 23/03/23.
//

import Foundation

class DatabaseStorageViewModel {
    var images = [Data]()
    
    func fetchImage(onCompletion: @escaping SingleResult<Bool>) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
            images = DatabaseHelper.shareInstance.fetchImage()
            onCompletion(true)
        }
    }
    
    func getDataCount() -> Int {
        return images.count
    }
}
