//
//  ContentView.swift
//  BabyTriage
//
//  Created by Pieter Jooste on 2022/08/17
//  with the help of Stewart Lynch https://youtu.be/yMC16EZHwZU,
//  Mohammad Azam https://youtu.be/6i7RD1laExA and
//  Moritz Recke https://github.com/create-with-swift/coreml-with-swiftui
//

import CoreML
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: ViewModel
    @FocusState var nameField:Bool
    
//    let model: BabyClassifier = {
//        do {
//            let config = MLModelConfiguration()
//            return try BabyClassifier(configuration: config)
//        } catch {
//            print(error)
//            fatalError("Couldn't create BabyClassifier")
//        }
//    }()

//    @State private var classificationLabel: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if !vm.isEditing {
                    imageScroll
                }
                selectedImage
                VStack {
                    if vm.image != nil {
                       editGroup
                    }
                    if !vm.isEditing {
                        pickerButtons
                    }
                    
                    Button("Classify") {
                        vm.classifyImage()
                        nameField = true
                    }
                    .padding()
                    .foregroundColor(Color.white)
                    .background(Color.green)
                    .cornerRadius(15)

                    Text(vm.classificationLabel)
                        .padding()
                        .font(.body)
                }
                .padding()
                Spacer()
            }
            .task {
                if FileManager().docExist(named: fileName) {
                    vm.loadMyImagesJSONFile()
                }
            }
            .sheet(isPresented: $vm.showPicker) {
                ImagePicker(sourceType: vm.source == .library ? .photoLibrary : .camera, selectedImage: $vm.image)
                    .ignoresSafeArea()
            }
            .alert("Error", isPresented: $vm.showFileAlert, presenting: vm.appError, actions: { cameraError in
                cameraError.button
            }, message: { cameraError in
                Text(cameraError.message)
            })
            .navigationTitle("Baby Triage")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            nameField = false
                        } label : {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel())
    }
}
