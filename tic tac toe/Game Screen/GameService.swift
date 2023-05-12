//
//  GameService.swift
//  tic tac toe
//
//  Created by Ash on 11/05/2023.
//

import SwiftUI

@MainActor
class GameService: ObservableObject {
    
    @Published var player1 = Player(gamePiece: .x, name: "Player 1")
    @Published var player2 = Player(gamePiece: .o, name: "Player 2")
    @Published var possibleMoves = Move.all
    @Published var gameOver = false
    @Published var gameBoard = GameSquare.reset
    
    @Published var isThinking = false
    
    var gameType = GameType.single
    
    
    var currentPlayer: Player {
        if player1.isCurrent {
            return player1
        } else {
            return player2
        }
    }
    
    var gameStarted: Bool {
        player1.isCurrent || player2.isCurrent || isThinking
    }
    
    var boardDisabled: Bool {
        gameOver || !gameStarted
    }
    
    func setupGame(gameType: GameType, player1Name: String, player2Name: String) {
        switch gameType {
        case .single:
            self.gameType = .single
            player2.name = player2Name
        case .cpu:
            self.gameType = .cpu
            player2.name = UIDevice.current.name
        case .peer:
            self.gameType = .peer
        case .undetermined:
            break
        }
        player1.name = player1Name
    }
    
    
    func reset() {
        player1.isCurrent = false
        player2.isCurrent = false
        player1.moves.removeAll()
        player2.moves.removeAll()
        gameOver = false
        possibleMoves = Move.all
        gameBoard = GameSquare.reset
    }
    
    func updateMoves(index: Int) {
        if player1.isCurrent {
            player1.moves.append(index + 1)
            gameBoard[index].player = player1
        } else {
            player2.moves.append(index + 1)
            gameBoard[index].player = player2
        }
    }
    
    func checkWinner() {
        if player1.isWinner || player2.isWinner {
            gameOver = true
        }
    }
    
    func toggleMoves() {
        player1.isCurrent.toggle()
        player2.isCurrent.toggle()
    }
    
    func makeMove(at index: Int) {
        if gameBoard[index].player == nil {
            withAnimation {
                updateMoves(index: index)
            }
            checkWinner()
            if !gameOver {
                if let matchingIndex = possibleMoves.firstIndex(where: {$0 == (index + 1) } ){
                    possibleMoves.remove(at: matchingIndex)
                }
                toggleMoves()
                if gameType == .cpu && currentPlayer.name == player2.name {
                    Task {
                        await CpuMove()
                    }
                }
            }
            if possibleMoves.isEmpty {
                gameOver = true
            }
        }
    }
    func CpuMove() async {
        isThinking.toggle()
        try?  await Task.sleep(nanoseconds: 100_000_000_0)
        if let move = possibleMoves.randomElement() {
            if let matchingIndex = Move.all.firstIndex(where: {$0 == move}) {
                makeMove(at: matchingIndex)
            }
        }
        isThinking.toggle()
    }
}
