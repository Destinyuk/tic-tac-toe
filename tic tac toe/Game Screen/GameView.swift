//
//  GameView.swift
//  tic tac toe
//
//  Created by Ash on 11/05/2023.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var game: GameService
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var connectionManager: MPConnectionManager
    var body: some View {
        VStack {
            if [game.player1.isCurrent, game.player2.isCurrent].allSatisfy({ $0 == false }) {
                Text("Select a player to start")
            }
            HStack {
                Button(game.player1.name) {
                    game.player1.isCurrent = true
                }
                .buttonStyle(PlayerButtonStyle(isCurrent: game.player1.isCurrent))
                
                
                Button(game.player2.name) {
                    game.player2.isCurrent = true
                    if game.gameType == .cpu {
                        Task {
                            await game.CpuMove()
                        }
                    }
                }
                .buttonStyle(PlayerButtonStyle(isCurrent: game.player2.isCurrent))
            }
            .disabled(game.gameStarted)
            VStack {
                HStack {
                    ForEach(0...2, id: \.self) { index in
                        SquareView(index: index)
                    }
                }
                HStack {
                    ForEach(3...5, id: \.self) { index in
                        SquareView(index: index)
                    }
                }
                HStack {
                    ForEach(6...8, id: \.self) { index in
                        SquareView(index: index)
                    }
                }
            }
            .overlay {
                if game.isThinking {
                    VStack {
                        Text("Thinking of a move")
                            .foregroundColor(Color(.systemBackground))
                            .background(Rectangle().fill(Color.primary))
                        ProgressView()
                    }
                }
            }
            .disabled(game.boardDisabled)
            VStack{
                if game.gameOver {
                    Text("Game Over")
                    if game.possibleMoves.isEmpty {
                        Text("Draw, No More Moves")
                    } else {
                        Text("\(game.currentPlayer.name) wins ")
                    }
                    Button("New Game") {
                        game.reset()
                        if game.gameType == .peer {
                            connectionManager.setup(game: game)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .font(.largeTitle)
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("End Game") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Tic tac toe")
        .inNavigationStack()
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(GameService())
            .environmentObject(MPConnectionManager(yourName: "testing"))
    }
}


struct PlayerButtonStyle: ButtonStyle {
    let isCurrent: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 12)
                .fill(isCurrent ? Color.blue : Color.gray))
            .foregroundColor(.white)
    }
}
