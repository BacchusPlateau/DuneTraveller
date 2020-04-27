//
//  Encounter.swift
//  DuneTraveller
//
//  Created by Bret Williams on 4/15/20.
//  Copyright © 2020 Bret Williams. All rights reserved.
//

import Foundation

class Encounter {
    
    var id: Int
    var name: String
    var type: String
    
    //this will hold a foreign key to the table indicated by 'type'
    var typeId: Int
    
    init() {
        id = 0
        typeId = 0
        name = ""
        type = ""
    }
}

class EncounterData {
    
    let getEncounterSqlTemplate = "SELECT * FROM Encounter WHERE id = %i;"
    
    func getEncounter(forId id: Int) -> Encounter {
        
        var encounter = Encounter()
        let getEncounterSql = String(format: getEncounterSqlTemplate, id)
        let sqlHelper = SQLHelper(databasePath: Globals.SharedInstance.databaseUrl)
        let result = sqlHelper.select(sqlCommand: getEncounterSql)
        
        encounter = mapResultToEntity(dataMatrix: result)[0]
        
        return encounter
        
    }
    
    func mapResultToEntity(dataMatrix result: [[String]]) -> [Encounter] {
                  
        var encounters = [Encounter]()
          
        for i in 0..<result.count {
                
            let encounter = Encounter()
            
            encounter.id = Int(result[i][0])!
            encounter.name = result[i][1]
            encounter.type = result[i][2]
            encounter.typeId = Int(result[i][3])!
            encounters.append(encounter)
      
        }
         
        return encounters
          
      }
    
}
