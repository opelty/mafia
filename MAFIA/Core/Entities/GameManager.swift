//
//  GameManager.swift
//  MAFIA
//
//  Created by Santiago Carmona Gonzalez on 1/4/18.
//  Copyright © 2018 Santiago Carmona Gonzalez. All rights reserved.
//

import Foundation

class GameManager {
    
    // MARK: - Vars & Constants
    
    static let currentGame = GameManager()
    
    private var selectedListPlayers: PlayersList?
    private var eliminatedPlayers: [Player] = [Player]()
    
    private init() {
        
    }
    
    var playersPlaying: [Player]? {
        return selectedListPlayers?.players
    }
    
    var listName: String? {
        return selectedListPlayers?.name
    }
    
    var numberOfPlayersPlaying: Int {
        return playersPlaying?.count ?? 0
    }
    
    /// Returns the number of civilians team players that are currently playing and are live
    var aliveCivilians: Int {
        get {
            let mafiaPlayers = numberOfPlayersPlaying / 3     //Esto sirve para calcular la cantidad de mafiosos.
            var civiliansPlaying = numberOfPlayersPlaying - mafiaPlayers
            civiliansPlaying = eliminatedPlayers.reduce(civiliansPlaying, {(result, player) -> Int in
                return player.role != .mob ? result - 1 : result
            })
            
            return civiliansPlaying
        }
    }
    
    /// Returns the number of mafia team players that are playing and are alive
    var aliveMafia: Int {
        get {
            var mafiaPlayers = numberOfPlayersPlaying / 3
            mafiaPlayers = eliminatedPlayers.reduce(mafiaPlayers, {(result, player) -> Int in
                return player.role == .mob ? result - 1 : result
            })
            return mafiaPlayers
        }
    }
    
    func setSelectedList(listPlayers: PlayersList) {
        selectedListPlayers = listPlayers
    }
    
    /// Adds a player to the `eliminatedPlayers` array.
    /// parameter player: The player to be kill from the current game
    func kill(_ player: Player) {
        eliminatedPlayers.append(player)
    }
    
    /// Removes a player from the `eliminatedPlayers` array
    /// parameter player: The player to be revived from the current game
    func revive(_ player: Player) {
        if let index = eliminatedPlayers.index(where: { $0.name == player.name}) {
            eliminatedPlayers.remove(at: index)
        }
    }
    
    func reviveAllKilledPlayers() {
        eliminatedPlayers.removeAll()
    }

    func removeForCurrentGame(player: Player) -> Bool {
        if let index = selectedListPlayers?.players.index(where: { $0.name == player.name}) {
            selectedListPlayers?.players.remove(at: index)
            return true
        }
        return false
    }
    
    func checkForKilledPlayers(player: Player) -> Bool {
        let filteredPlayer = eliminatedPlayers.filter { (playerToSearch) -> Bool in
            if player.name == playerToSearch.name {
                return true
            } else {
                return false
            }
        }
        if filteredPlayer.count == 0 {
            return false
        } else {
            return true
        }
    }
    
}
