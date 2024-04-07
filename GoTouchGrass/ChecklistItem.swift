//
//  ChecklistItem.swift
//  GoTouchGrass
//
//  Created by Sean Dudo on 4/7/24.
//

import Foundation

class ChecklistItem {
    let title:String
    var isChecked: Bool = false
    
    init(title: String) {
        self.title = title
    }
}
