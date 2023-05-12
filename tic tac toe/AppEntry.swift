//
//  tic_tac_toeApp.swift
//  tic tac toe
//
//  Created by Ash on 11/05/2023.
//

import SwiftUI

@main
struct AppEntry: App {
    @StateObject var game = GameService()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(game)
        }
    }
}
