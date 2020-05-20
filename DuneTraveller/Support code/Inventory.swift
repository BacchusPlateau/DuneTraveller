//
//  Inventory.swift
//  PlayAround
//
//  Created by Bret Williams on 3/31/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation

class Inventory {

    var items = [Item]()
    var notes = [Note]()
    
    func MergeInventory(withInventory inventory: Inventory) {
        
        inventory.items.forEach { item in
            items.append(item)
        }
        
        inventory.notes.forEach { note in
            notes.append(note)
        }
        
    }
    
    func getInventoryCount() -> Int {
        
        var total : Int = 0
        
        total += items.count + notes.count
        
        return total
        
    }
    
    
}
