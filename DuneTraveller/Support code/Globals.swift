//
//  Globals.swift
//  DuneTraveller
//
//  Created by Bret Williams on 4/15/20.
//  Copyright © 2020 Bret Williams. All rights reserved.
//

import Foundation

class Globals {

var databaseUrl: String

    class var SharedInstance: Globals {
        struct Singleton {
            static let instance = Globals()
        }
        
        return Singleton.instance
    }

    init() {
        
        databaseUrl = ""
        
    }

}
