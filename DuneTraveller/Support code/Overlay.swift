//
//  Overlay.swift
//  DuneTraveller
//
//  Created by Bret Williams on 4/15/20.
//  Copyright © 2020 Bret Williams. All rights reserved.
//

import Foundation

class Overlay {
    
    var id: Int
    var level: Int
    var volatile: Bool
    var encounterId: Int
    var itemIdDependency: Int
    var description: String
    var completed: Bool
    var encounterIdDependency: Int
    var xCoordinate: Int
    var yCoordinate: Int
    
    init() {
        
        id = -1
        level = -1
        volatile = false
        encounterId = -1
        itemIdDependency = -1
        description = ""
        completed = false
        encounterIdDependency = -1
        xCoordinate = 0
        yCoordinate = 0
        
    }
    
}

class OverlayData {
    
    let getOverlayDataForLevelSql = "SELECT * FROM Overlay WHERE level = %d;"
    
    func getOverlayData(forLevel level: Int) -> [Overlay]  {
        
        var overlay = [Overlay]()
        let getOverlaySql = String(format: getOverlayDataForLevelSql, level)
        let sqlHelper = SQLHelper(databasePath: Globals.SharedInstance.databaseUrl)
        let result = sqlHelper.select(sqlCommand: getOverlaySql)
        overlay = mapResultToEntity(dataMatrix: result)
        
        return overlay
        
    }
    
    func mapResultToEntity(dataMatrix result: [[String]]) -> [Overlay] {
        
            
        var overlayCollection = [Overlay]()
        
        for i in 0..<result.count {
              
            let overlay = Overlay()
        
            overlay.id = Int(result[i][0])!
            overlay.level = Int(result[i][1])!
            
            if(result[i][2] == "1") {
                overlay.volatile = true
            }
                        
            overlay.encounterId = Int(result[i][3])!
            overlay.itemIdDependency = Int(result[i][4])!
            overlay.description = result[i][5]
            
            if(result[i][6] == "1") {
                overlay.completed = true
            }
            
            overlay.encounterIdDependency = Int(result[i][7])!
            overlay.xCoordinate = Int(result[i][8])!
            overlay.yCoordinate = Int(result[i][9])!
            
            overlayCollection.append(overlay)
                   
      }
       
      return overlayCollection
        
    }
    
}
