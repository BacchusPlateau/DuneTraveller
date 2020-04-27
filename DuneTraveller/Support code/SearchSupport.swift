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
    }
    
}

class SearchAreaData {
    
    let getSearchAreaDataSqlTemplate = "SELECT * FROM SearchArea WHERE id = %i;"
    
    func getIventoryFoundInSearch() {
     
        //don't forget notes can be inventory too
        
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
