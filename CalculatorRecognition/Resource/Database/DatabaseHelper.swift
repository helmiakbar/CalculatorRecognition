//
//  DatabaseHelper.swift
//  CalculatorRecognition
//
//  Created by tamu on 23/03/23.
//

import Foundation
import UIKit
import CoreData
import CryptoSwift

class DatabaseHelper {
    static let shareInstance = DatabaseHelper()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let iv = AES.randomIV(AES.blockSize)
    
    private func getKey() -> String {
        let password: [UInt8] = Array("s33krit".utf8)
        let salt: [UInt8] = Array("nacllcan".utf8)
        
        let key = try! PKCS5.PBKDF2(
            password: password,
            salt: salt,
            iterations: 4096,
            keyLength: 32, /* AES-256 */
            variant: .sha2(.sha256)
        ).calculate()
        return key.toHexString()
    }
    
    private func checkKey() -> String {
        if DataManager.sharedInstance.getKey() == "" {
            DataManager.sharedInstance.setKey(text: getKey())
        }
        return DataManager.sharedInstance.getKey()
    }
    
    private func checkIV() -> [UInt8] {
        if DataManager.sharedInstance.getIV().count == 0 {
            DataManager.sharedInstance.setIV(value: iv)
        }
        return DataManager.sharedInstance.getIV()
    }
    
    func saveImage(data: Data) {
        let keyArray = [UInt8](hex: checkKey())
        let aes = try! AES(key: keyArray, blockMode: CBC(iv: checkIV()), padding: .pkcs7)
        let encryptedData = try! aes.encrypt(data.bytes)
        let entity = NSEntityDescription.entity(forEntityName: "Image", in: context)!
        let object = NSManagedObject(entity: entity, insertInto: context)
        object.setValue(Data(encryptedData), forKey: "img")
        do {
            try context.save()
            print("Image is saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage() -> [Data] {
        var fetchingImage = [Data]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        let fetchImages =  try! context.fetch(fetchRequest) as! [NSManagedObject]
        let keyArray = [UInt8](hex: checkKey())

        for image in fetchImages {
            let encryptedData = image.value(forKey: "img") as! Data
            let decryptedData = try! AES(key: keyArray, blockMode: CBC(iv: checkIV()), padding: .pkcs7).decrypt(encryptedData.bytes)
            fetchingImage.append(Data(decryptedData))
        }
        return fetchingImage
    }
}
