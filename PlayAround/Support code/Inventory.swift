//
//  Inventory.swift
//  PlayAround
//
//  Created by Bret Williams on 3/31/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class Inventory : SKSpriteNode {

    var theCount:Int = 0
    var countLabel:SKLabelNode = SKLabelNode()
    var showCount:Bool = false
    var offset:CGPoint = CGPoint.zero
    var slotUsed:String = ""
    
    func setUpWithDict(theDict: [String:Any]) {
        
        for (key, value) in theDict {
            
            switch key {
            case "ShowCount":
                if (value is Bool) {
                    showCount = value as! Bool
                }
            case "CountOffset":
                if (value is String) {
                    offset = CGPointFromString(value as! String)
                }
            default:
                continue
            }
        }
        
        if (showCount) {
            
            countLabel.zPosition = self.zPosition + 1
            self.addChild(countLabel)
            countLabel.position = offset
            countLabel.fontSize = 32
            countLabel.fontName = "Helvetica Neue"
            updateLabel()
            
        }
        
    }
    
    func updateLabel() {
        
        countLabel.text = String(theCount)
    }







}
