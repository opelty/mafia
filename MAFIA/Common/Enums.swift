//
//  Enums.swift
//  MAFIA
//
//  Created by Santiago Carmona Gonzalez on 12/19/17.
//  Copyright © 2017 Santiago Carmona Gonzalez. All rights reserved.
//

import Foundation

/// All the roles which will be used on the app
enum Role { // TODO: This might change in the future if we are going to add the feature of add custom Roles.
    case king,
    doctor,
    sheriff,
    villager,
    mob,
    none
    
    var imageDescription: String {
        return String(describing: self)
    }
    var roleDescription: String {
        return String(describing: self).localized().capitalizeFirst()
    }
}
