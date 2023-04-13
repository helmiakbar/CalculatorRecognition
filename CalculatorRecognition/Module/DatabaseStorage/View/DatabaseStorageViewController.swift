//
//  DatabaseStorageViewController.swift
//  CalculatorRecognition
//
//  Created by tamu on 23/03/23.
//

import UIKit
import SkeletonView

protocol DatabaseStorageDelegate {
    func loadImageFormDatabase(data: Data?)
}

class DatabaseStorageViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    let viewModel = DatabaseStorageViewModel()
    var delegate: DatabaseStorageDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Storage List"
        viewModel.fetchImage(onCompletion: reloadCollectionView())
        
        self.noDataLbl.isHidden = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "DatabaseStorageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DatabaseStorageCollectionViewCell")
        collectionView.reloadData()
        collectionView.showAnimatedSkeleton()
    }
    
    func reloadCollectionView() -> SingleResult<Bool> {
        return { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.hideSkeleton()
            self.collectionView.reloadData()
            if self.viewModel.getDataCount() == 0 {
                self.noDataLbl.isHidden = false
                self.collectionView.isHidden = true
            } else {
                self.noDataLbl.isHidden = true
                self.collectionView.isHidden = false
            }
        }
    }
}

extension DatabaseStorageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getDataCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DatabaseStorageCollectionViewCell", for: indexPath) as? DatabaseStorageCollectionViewCell {
            cell.setupData(dataImage: viewModel.images[indexPath.row])
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.loadImageFormDatabase(data: viewModel.images[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 32)/3.4, height: 168)
    }
}

extension DatabaseStorageViewController: SkeletonCollectionViewDataSource {
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return String(describing: DatabaseStorageCollectionViewCell.self)
    }
}
