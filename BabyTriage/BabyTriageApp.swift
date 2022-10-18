//
//  BabyTriageApp.swift
//  BabyTriage
//
//  Created by Pieter Jooste on 2022/08/17.
//  with the help of Stewart Lynch https://youtu.be/yMC16EZHwZU,
//  Mohammad Azam https://youtu.be/6i7RD1laExA and
//  Moritz Recke https://github.com/create-with-swift/coreml-with-swiftui
//

import SwiftUI

@main
struct BabyTriageApp: App {
    @StateObject var vm = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ViewModel())
                .onAppear {
                    UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                }
        }
    }
}
