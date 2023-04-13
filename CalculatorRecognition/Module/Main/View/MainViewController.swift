//
//  MainViewController.swift
//  CalculatorRecognition
//
//  Created by tamu on 22/03/23.
//

import UIKit
import SkeletonView

class MainViewController: UIViewController {
    @IBOutlet weak var detectedTextLbl: UILabel!
    @IBOutlet weak var resultTextLbl: UILabel!
    let viewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }
    
    //MARK: - ButtonAction
    @IBAction func addInputBtn(_ sender: Any) {
        showActionSheetForSelectedImage()
    }
}

private extension MainViewController {
    //MARK: - setupNavigation
    func setupNavigation() {
        self.navigationItem.title = "Calculator Recognition"
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = viewModel.themeColor
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    //MARK: - showActionSheetForSelectedImage
    func showActionSheetForSelectedImage() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let firstAction: UIAlertAction =  UIAlertAction(title: "Choose database storage", style: .default) { action -> Void in
            self.goToDatabaseView()
        }
        
        var secondAction: UIAlertAction
        #if AppRedBuiltInCamera
        secondAction = UIAlertAction(title: "Camera", style: .default) { action -> Void in
                self.openCamera()
            }
        #elseif AppRedCameraRoll || AppGreenCameraRoll
        secondAction = UIAlertAction(title: "Photos", style: .default) { action -> Void in
                self.openGallary()
            }
        #elseif AppGreenFilesystem
        secondAction = UIAlertAction(title: "Files", style: .default) { action -> Void in
                self.openFileSystem()
            }
        #endif
                
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
                
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
                
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
                
        present(actionSheetController, animated: true, completion: nil)
    }
    
    // MARK: - CameraAndPhotos
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
            
    func openGallary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK: - databaseView
    func goToDatabaseView() {
        let databaseVC = DatabaseStorageViewController()
        databaseVC.delegate = self
        self.navigationController?.pushViewController(databaseVC, animated: true)
    }
    
    //MARK: - openFileSystem
    func openFileSystem() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.image", "public.jpeg", "public.png"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    //MARK: - handle Result
    func onHandleTextRecognition() -> DoubleResult<Bool, String?> {
        showSkeloton(false)
        return { [weak self] status, _ in
            guard let self = self else { return }
            if status {
                self.detectedTextLbl.text = self.viewModel.textWord
                self.resultTextLbl.text = "\(self.viewModel.resultSolver)"
            } else {
                self.showAlert()
            }
        }
    }
    
    //MARK: - shoeAlert
    func showAlert() {
        let alert = UIAlertController(title: "", message: "Sorry we can't read the expression. Maybe you can try with another image", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {
            (alert: UIAlertAction!) in
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - showSkeloton
    func showSkeloton(_ isLoading: Bool = true) {
        if isLoading {
            detectedTextLbl.showAnimatedSkeleton()
            resultTextLbl.showAnimatedSkeleton()
        } else {
            detectedTextLbl.hideSkeleton()
            resultTextLbl.hideSkeleton()
        }
    }
}

extension MainViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        showSkeloton(true)
        self.dismiss(animated:true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
                self.viewModel.readImage(image: image, onCompletion: self.onHandleTextRecognition())
            }
        })
    }
}

extension MainViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        defer {
            DispatchQueue.main.async {
                url.stopAccessingSecurityScopedResource()
            }
        }
        guard let image = UIImage(contentsOfFile: url.path) else { return }
        showSkeloton()
        controller.dismiss(animated: false, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
                self.viewModel.readImage(image: image, onCompletion: self.onHandleTextRecognition())
            }
        })
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}

extension MainViewController: DatabaseStorageDelegate {
    func loadImageFormDatabase(data: Data?) {
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.transitionCoordinator?.animate(alongsideTransition: nil) { _ in
            if let validData = data {
                guard let image = UIImage(data: validData) else {
                    self.showAlert()
                    return
                }
                self.viewModel.readImage(image: image, onCompletion: self.onHandleTextRecognition())
            }
        }
    }
}

