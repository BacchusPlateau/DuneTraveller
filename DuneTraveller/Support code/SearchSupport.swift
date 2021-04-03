//
//  SearchSupport.swift
//  DuneTraveller
//
//  Created by Bret Williams on 4/21/20.
//  Copyright © 2020 Bret Williams. All rights reserved.
//

import Foundation

class SearchArea {
    
    var id: Int
    var tilePosition: CGPoint
    var scenePosition: CGPoint
    var message: String
    var items: [Int]
    var searchRadius: Int
    var encounterId: Int
    
    init() {
        
        //we are using the tile map coordinates here for easier search collision hit detection, determined at runtime
        //not a good idea to use the tile map coordinate system for computation - it will change if you add more tiles for
        //example
        tilePosition = CGPoint.zero
        
        //coordinates in the sene
        scenePosition = CGPoint.zero
        
        //this shows when the search hits the area
        message = ""
        
        //holds the inventory item id of each of the items found
        items = [Int]()
        
        //this is how many squares around the player's position do we look for a collision hit
        searchRadius = 1
        
        id = -1
        
        //this is a pointer into the Encounter array.  We want to remove the SearchArea from the global array
        //if the encounter.volatile == true if the searchArea was found
        encounterId = -1
        
    }
    
}

class SearchAreaData {
    
    let getSearchAreaDataSqlTemplate = "SELECT * FROM SearchArea WHERE id = %i;"
    let getSearchResultDataSqlTemplate = "SELECT * FROM SearchResult WHERE searchAreaId = %i;"
    
    func getIventoryFoundInSearch(forSearchAreaId id:Int) -> Inventory {
     
        var inventory = Inventory()
        let getSearchResultSql = String(format: getSearchResultDataSqlTemplate, id)
        
        print("Search result sql = " + getSearchResultSql)
        
        let sqlHelper = SQLHelper(databasePath: Globals.SharedInstance.databaseUrl)
        let result = sqlHelper.select(sqlCommand: getSearchResultSql)
        
        inventory = mapResultToItemTypes(dataMatrix: result)
        
        return inventory
        
    }
    
    func mapResultToItemTypes(dataMatrix result: [[String]]) -> Inventory {
        
        var typeId : Int = -1
        var type : String = ""
        let inventory : Inventory = Inventory()
        
        for i in 0..<result.count {
            
            typeId = Int(result[i][1])!
            type = result[i][2]
            
            switch type {
            case "note":
                let noteData = NoteData()
                let note = noteData.getNote(forNoteId: typeId)
                inventory.notes.append(note)
            case "item":
                let itemData = ItemData()
                let item = itemData.getItem(forId: typeId)
                inventory.items.append(item)
            default:
                break
            }
            
        }
        
        return inventory
        
    }
    
    
    func getSearchAreaDetail(forSearchAreaId id:Int) -> SearchArea {
        
        var searchArea = SearchArea()
        let getSearchAreaSql = String(format: getSearchAreaDataSqlTemplate, id)
        let sqlHelper = SQLHelper(databasePath: Globals.SharedInstance.databaseUrl)
        let result = sqlHelper.select(sqlCommand: getSearchAreaSql)
        
        searchArea = mapResultToEntity(dataMatrix: result)[0]
        
        return searchArea
        
    }
    
    func mapResultToEntity(dataMatrix result: [[String]]) -> [SearchArea] {
        
        var areas = [SearchArea]()
        
        for i in 0..<result.count {
            
            let area = SearchArea()
            
            area.id = Int(result[i][0])!
            area.message = result[i][2]
            
            areas.append(area)
        }
        
        return areas
    }
    
}
