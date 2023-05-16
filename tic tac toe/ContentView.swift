//
//  ContentView.swift
//  tic tac toe
//
//  Created by Ash on 11/05/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var gameType: GameType = .undetermined
    @AppStorage("yourName") var yourName = ""
    @State private var opponentsName = ""
    @State private var startGame = false
    @State private var changeName = false
    @State private var newName = ""
    
    @FocusState private var focus: Bool
    
    @EnvironmentObject var game: GameService
    
    
    init(yourNamne: String) {
        self.yourName = yourName
    }
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
                        TextField("Opponents Name", text: $opponentsName)
                case .cpu:
                        EmptyView()
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
                    gameType == .single && opponentsName.isEmpty
                )
                Text("Your current name is \(yourName)")
                Button("Change my name") {
                    changeName.toggle()
                }
                .buttonStyle(.borderedProminent)
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
        .alert("Change Name", isPresented: $changeName, actions: {
            TextField("New Name", text: $newName)
            Button("OK", role: .destructive) {
                yourName = newName
                exit(-1)
            }
            Button("Cancel", role: .cancel) {}
        }, message: {
           Text( "Tapping on the OK button will quit the application so you can relaunch to use your change name.")
        })
        .inNavigationStack()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(yourNamne: "Test")
            .environmentObject(GameService())
    }
}
