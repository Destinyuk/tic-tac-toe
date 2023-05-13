//
//  tic_tac_toeApp.swift
//  tic tac toe
//
//  Created by Ash on 11/05/2023.
//

import SwiftUI

@main
struct AppEntry: App {
    @AppStorage("yourName") var yourName = ""
    @StateObject var game = GameService()
    var body: some Scene {
        WindowGroup {
            if yourName.isEmpty {
                YourNameView()
            } else {
                
                ContentView(yourNamne: yourName)
                    .environmentObject(game)
            }
        }
    }
}
