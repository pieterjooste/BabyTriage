//
//  ViewModel.swift
//  ViewModel
//
//  Created by Stewart Lynch on 2021-08-15.
//

import CoreML
import SwiftUI

class ViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var showPicker = false
    @Published var source: Picker.Source = .library
    @Published var showCameraAlert = false
    @Published var cameraError: Picker.CameraErrorType?
    @Published var imageName: String = ""
    @Published var isEditing = false
    @Published var selectedImage: MyImage?
    @Published var myImages: [MyImage] = []
    @Published var showFileAlert = false
    @Published var appError: MyImageError.ErrorType?
    @Published var classificationLabel: String = ""
    
    let model: BabyClassifier = {
        do {
            let config = MLModelConfiguration()
            return try BabyClassifier(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create BabyClassifier")
        }
    }()
    
    init() {
        print(FileManager.docDirURL.path)
    }
    
    var buttonDisabled: Bool {
        imageName.isEmpty || image == nil
    }
    
    var deleteButtonIsHidden: Bool {
        isEditing || selectedImage == nil
    }
    
    func showPhotoPicker() {
        do {
            if source == .camera {
                try Picker.checkPermissions()
            }
            showPicker = true
        } catch {
            showCameraAlert = true
            cameraError = Picker.CameraErrorType(error: error as! Picker.PickerError)
        }
    }
    
    func reset() {
        image = nil
        imageName = ""
        isEditing = false
        selectedImage = nil
        classificationLabel = ""
    }
    
    func display(_ myImage: MyImage) {
        image = myImage.image
        imageName = myImage.name
        selectedImage = myImage
    }
    
    func updateSelected() {
        if let index = myImages.firstIndex(where: {$0.id == selectedImage!.id}) {
            myImages[index].name = imageName
            saveMyImagesJSONFile()
            reset()
        }
    }
    
    func deleteSelected() {
        if let index = myImages.firstIndex(where: {$0.id == selectedImage!.id}) {
            myImages.remove(at: index)
            saveMyImagesJSONFile()
            reset()
        }
    }
    
    func addMyImage(_ name: String, image: UIImage) {
        reset()
        let myImage = MyImage(name: name)
        do {
            try FileManager().saveImage("\(myImage.id)", image: image)
            myImages.append(myImage)
            saveMyImagesJSONFile()
            reset()
        } catch {
            showFileAlert = true
            appError = MyImageError.ErrorType(error: error as! MyImageError)
        }
    }
    
    func saveMyImagesJSONFile() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(myImages)
            let jsonString = String(decoding: data, as: UTF8.self)
            reset()
            do {
                try FileManager().saveDocument(contents: jsonString)
            } catch {
                showFileAlert = true
                appError = MyImageError.ErrorType(error: error as! MyImageError)
            }
        } catch {
            showFileAlert = true
            appError = MyImageError.ErrorType(error: .encodingError)
        }
    }
    
    func loadMyImagesJSONFile() {
        do {
            let data = try FileManager().readDocument()
            let decoder = JSONDecoder()
            do {
                myImages = try decoder.decode([MyImage].self, from: data)
            } catch {
                showFileAlert = true
                appError = MyImageError.ErrorType(error: .decodingError)
            }
        } catch {
            showFileAlert = true
            appError = MyImageError.ErrorType(error: error as! MyImageError)
        }
    }
    
    func classifyImage() {
        
        guard let image = image else {
            classificationLabel = "Select an image to classify"
            return }
        classificationLabel = ""
        guard let resizedImage = image.resizeImageTo(size:CGSize(width: 299, height: 299)), let buffer = resizedImage.convertToBuffer() else { return }
        
        let output = try? model.prediction(image: buffer)
        
        if let output = output {
            let results = output.classLabelProbs.sorted { $0.1 > $1.1 }
            let result = results.map { (key, value) in
                return "\(key) = \(String(format: "%.2f", value * 100))%"
            }.joined(separator: ", ")

            classificationLabel = result
        }
    }
}
