//
//  DatabaseStorageCollectionViewCell.swift
//  CalculatorRecognition
//
//  Created by tamu on 23/03/23.
//

import UIKit

class DatabaseStorageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupData(dataImage: Data?) {
        if let validDataImage = dataImage {
            imageView.image = UIImage(data: validDataImage)
        }
    }
}
