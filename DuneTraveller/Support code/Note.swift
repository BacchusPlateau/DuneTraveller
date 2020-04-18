//
//  Note.swift
//  DuneTraveller
//
//  Created by Bret Williams on 4/18/20.
//  Copyright © 2020 Bret Williams. All rights reserved.
//

import Foundation

class Note {
    
    var id: Int
    var encounterId: Int
    var content: String
    
    init() {
        id = -1
        encounterId = -1
        content = ""
    }
    
}

class NoteData {
    
    let getNoteDataSqlTemplate = "SELECT * FROM Note WHERE encounterId = %i;"
    
    func getNote(forEncounterId id:Int) -> Note {
        
        var note = Note()
        let getNoteSql = String(format: getNoteDataSqlTemplate, id)
        let sqlHelper = SQLHelper(databasePath: Globals.SharedInstance.databaseUrl)
        let result = sqlHelper.select(sqlCommand: getNoteSql)
        
        note = mapResultToEntity(dataMatrix: result)[0]
        
        return note
    }
    
    func mapResultToEntity(dataMatrix result: [[String]]) -> [Note] {
        
        var notes = [Note]()
        
        for i in 0..<result.count {
            
            let note = Note()
            
            note.id = Int(result[i][0])!
            note.encounterId = Int(result[i][1])!
            note.content = result[i][2]
            
            notes.append(note)
        }
        
        return notes
    }
    
}
