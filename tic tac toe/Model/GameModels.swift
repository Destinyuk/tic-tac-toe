//
//  GameModels.swift
//  tic tac toe
//
//  Created by Ash on 11/05/2023.
//

import SwiftUI

enum GameType {
    case single, cpu, peer, undetermined
    
    var description: String {
        switch self {
        case .single:
          return  "Share your device to play this game"
        case .cpu:
           return "Play vs the cpu"
        case .peer:
           return "Invite someone nearby to play"
        case .undetermined:
            return ""
        }
    }
}
enum GamePiece: String {
    case x, o
    var image: Image {
        Image(self.rawValue)
    }
}

struct Player {
    let gamePiece: GamePiece
    var name: String
    var moves: [Int] = []
    var isCurrent = false
    var isWinner: Bool {
        for moves in Move.winningMoves {
            if moves.allSatisfy(self.moves.contains) {
                return true
            }
        }
        return false
    }
}

enum Move {
    static var all = [1,2,3,4,5,6,7,8,9]

    static var winningMoves = [
        [1,2,3],
        [4,5,6],
        [7,8,9],
        [1,4,7],
        [2,5,8],
        [3,6,9],
        [1,5,9],
        [3,5,7]
    ]
}
