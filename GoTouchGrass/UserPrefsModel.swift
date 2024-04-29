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
    var prefParks:Bool
    var prefRec:Bool
    var prefShop:Bool
    
    var totalTime:Int
    var tasksCompleted:Int
    var numBreaks:Int
    
    var locRadius:Float
}
