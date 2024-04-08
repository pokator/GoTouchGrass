//
//  UserPrefsModel.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/29/24.
//

import Foundation

struct UserPrefsModel: Identifiable, Codable {
    var id: String?
    var username: String
    
    var prefFood:Bool
    var prefGym:Bool
    var prefRec:Bool
    var prefShop:Bool
    
    var timeDone:Int
    var totalTime:Int
    var taskNum:Int
    
    var locRadius:Float
}
