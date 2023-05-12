//
//  ContentView.swift
//  tic tac toe
//
//  Created by Ash on 11/05/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var gameType: GameType = .undetermined
    @State private var yourName = ""
    @State private var opponentsName = ""
    @State private var startGame = false
    
    @FocusState private var focus: Bool
    
    @EnvironmentObject var game: GameService
    
    var body: some View {
        
        VStack {
            Picker("Select a Game", selection: $gameType) {
                Text("Select a Game Type").tag(GameType.undetermined)
                Text("Two Player Game").tag(GameType.single)
                Text("Play the CPU").tag(GameType.cpu)
                Text("Challenge a friend").tag(GameType.peer)
            }
            
            .padding()
            .background(RoundedRectangle(cornerRadius: 10, style: .circular).stroke(lineWidth: 5))
            .accentColor(.secondary)
            
            Text(gameType.description)
                .padding()
            VStack{
                switch gameType {
                case .single:
                    VStack {
                        TextField("Your Name", text: $yourName)
                        TextField("Opponents Name", text: $opponentsName)
                    }
                case .cpu:
                    TextField("Your Name", text: $yourName)
                case .peer:
                    EmptyView()
                case .undetermined:
                    EmptyView()
                }
            }
            .textFieldStyle(.roundedBorder)
            .focused($focus)
            .frame(width: 350)
            
            if gameType != .peer {
                Button("Start Game") {
                    game.setupGame(gameType: gameType, player1Name: yourName, player2Name: opponentsName)
                    focus = false
                    startGame.toggle()
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    gameType == .undetermined ||
                    gameType == .cpu && yourName.isEmpty ||
                    gameType == .single && (yourName.isEmpty || opponentsName.isEmpty)
                )
            }
    
        }
        .padding()
        .navigationTitle("Tic tac toe")
        .onAppear {
            game.reset()
        }
        .fullScreenCover(isPresented: $startGame) {
            GameView()
        }
        .inNavigationStack()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GameService())
    }
}
