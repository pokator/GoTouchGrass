//
//  UserPrefsModel.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/29/24.
//

import Foundation

struct UserPrefsModel: Identifiable, Codable {
    var id: String?
    var text: String
    
    var pref0:Bool
    var pref1:Bool
    
    var locRadius:Float
}
