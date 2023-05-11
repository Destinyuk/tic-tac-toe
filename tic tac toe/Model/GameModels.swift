//
//  GameModels.swift
//  tic tac toe
//
//  Created by Ash on 11/05/2023.
//

import Foundation

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
