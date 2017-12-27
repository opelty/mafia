//
//  Enums.swift
//  MAFIA
//
//  Created by Santiago Carmona Gonzalez on 12/19/17.
//  Copyright © 2017 Santiago Carmona Gonzalez. All rights reserved.
//

import Foundation


enum Role {
    case king,
    doctor,
    sheriff,
    civilian,
    mafia,
    none
    
    var imageDescription: String {
        return String(describing: self)
    }
}

enum MenuOptions: String {
    
    case NewPlayer = "MENU_ADD_NEW_PLAYER"
    case PlayersList = "MENU_PLAYERS_LIST"
    
    var title: String {
        return self.rawValue.localized()
    }
}
    

