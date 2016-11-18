//
//  enum.swift
//  GameFace
//
//  Created by Stanley Chiang on 10/13/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import Foundation

enum GameState:String {
    case preGame
    case inPlay
    case paused
    case postGame
}

enum GameItem:String {
    case glasses
}

enum PlayerAttribute:String {
    case id
    case username
    case email
    case phone
    case highscore
}

enum PowerUp:String {
    case slomo
    case catchall
}

enum PlayerEvent:String {
    case player_started_playing //isFirstTimePlaying, isfrompostgamemodal
    case player_finished_game
    case player_reset_game //isWhileInGame
    case player_exited_app //isWhileInGame
    case player_tapped_share
}
