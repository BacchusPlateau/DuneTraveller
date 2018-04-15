//
//  SharedHelpers.swift
//  PlayAround
//
//  Created by Bret Williams on 1/20/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class SharedHelpers {
    
    
    static func checkIfSKSExists( baseSKSName:String) -> (String,Bool) {
        
        var fullSKSNameToLoad:String = baseSKSName
        var hasCustomPad:Bool = false
        
        if( UIDevice.current.userInterfaceIdiom == .pad) {
            
            if let _ = GameScene(fileNamed: baseSKSName + "Pad") {
                fullSKSNameToLoad = baseSKSName + "Pad"
                hasCustomPad = true
            }
            
        } else if (UIDevice.current.userInterfaceIdiom == .phone ) {
            if let _ = GameScene(fileNamed: baseSKSName + "Phone") {
                fullSKSNameToLoad = baseSKSName + "Phone"
            }
        }
        
        return (fullSKSNameToLoad,hasCustomPad)
    }
    
    
}
