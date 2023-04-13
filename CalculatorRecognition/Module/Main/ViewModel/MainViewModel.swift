//
//  MainViewModel.swift
//  CalculatorRecognition
//
//  Created by tamu on 22/03/23.
//

import Foundation
import Vision
import UIKit

let pattern = "([0-9]+[\\+\\-\\*\\/]{1}[0-9])"
let symbols = "([\\+\\-\\*\\/]{1})"

class MainViewModel {
    var textWord: String = ""
    @Published var resultSolver: Int = 0
    
    var themeColor: UIColor {
    #if AppRedBuiltInCamera || AppRedCameraRoll
        return UIColor.red
    #elseif AppGreenFilesystem || AppGreenCameraRoll
        return UIColor.green
    #endif
    }
}

extension MainViewModel {
    func readImage( image: UIImage, onCompletion: @escaping DoubleResult<Bool, String?>) {
        guard let cgImage = image.cgImage else { return }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                onCompletion(false, nil)
                return
            }
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")
            guard let arrayExpression = text.matches(for: pattern).first else {
                onCompletion(false, nil)
                return
            }
            self.textWord = arrayExpression
            guard let operation = arrayExpression.matches(for: symbols).first else { return }
            let arguments = arrayExpression.components(separatedBy: operation)
            debugPrint(">> \(arguments)")
            
            if let value1 = arguments.first, let value2 = arguments.last, let intVal1 = Int(value1.trimmingCharacters(in: .whitespacesAndNewlines)), let intVal2 = Int(value2.trimmingCharacters(in: .whitespacesAndNewlines)) {
                self.resultSolver = self.expressionSolver(
                    a: intVal1,
                    b: intVal2,
                    operatorSymbol: operation
                )
                if let imageData = image.pngData() {
                    DatabaseHelper.shareInstance.saveImage(data: imageData)
                }
                onCompletion(true, nil)
            } else {
                onCompletion(false, nil)
            }
        }
        request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
        try? handler.perform([request])
    }

  func expressionSolver<T: Numeric & BinaryInteger>(a: T, b: T, operatorSymbol: String) -> T {
      var total: T = 0
      switch operatorSymbol {
      case "+":
          total = a + b
      case "-":
          total = a - b
      case "/":
          total = a / b
      case "*":
          total = a * b
      default:
          break
      }
      return total
    }
}
