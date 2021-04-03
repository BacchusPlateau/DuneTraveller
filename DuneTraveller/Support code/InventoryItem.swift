//
//  InventoryItem.swift
//  DuneTraveller
//
//  Created by Bret Williams on 5/20/20.
//  Copyright © 2020 Bret Williams. All rights reserved.
//

import Foundation

class Item {
    
    var id: Int
    var name: String
    var description: String
    var narrative: String
    var type: String

    init() {
        
        id = -1
        name = ""
        
        //this is an explanation for the programmer
        description = ""
        
        //this is what the player will see when the item is found or re-examined once in the inventory
        narrative = ""
        
        //so far, this will be a key or a weapon.
        //enum?
        type = ""
        
    }
    
}

class ItemData {
    
    let getItemSqlTemplate = "SELECT * FROM Item WHERE id = %i;"
    
    func getItem(forId id: Int) -> Item {
        
        var item = Item()
        let getItemSql = String(format: getItemSqlTemplate, id)
        let sqlHelper = SQLHelper(databasePath: Globals.SharedInstance.databaseUrl)
        let result = sqlHelper.select(sqlCommand: getItemSql)
        
        item = mapResultToEntity(dataMatrix: result)[0]
        
        return item
        
    }
    
    func mapResultToEntity(dataMatrix result: [[String]]) -> [Item] {
        
        var items = [Item]()
        
        for i in 0..<result.count {
            
            let item = Item()
            
            item.id = Int(result[i][0])!
            item.name = result[i][1]
            item.description = result[i][2]
            item.narrative = result[i][3]
            item.type = result[i][4]
            
            items.append(item)
        }
        
        return items
        
    }
    
}


