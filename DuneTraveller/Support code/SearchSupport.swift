//
//  SearchSupport.swift
//  DuneTraveller
//
//  Created by Bret Williams on 4/21/20.
//  Copyright © 2020 Bret Williams. All rights reserved.
//

import Foundation

class SearchArea {
    
    var tilePosition: CGPoint
    var message: String
    var items: [Int]
    var searchRadius: Int
    
    init() {
        
        //we are using the tile map coordinates here for easier search collision hit detection
        tilePosition = CGPoint.zero
        
        //this shows when the search hits the area
        message = ""
        
        //holds the inventory item id of each of the items found
        items = [Int]()
        
        //this is how many squares around the player's position do we look for a collision hit
        searchRadius = 1
        
    }
    
}
