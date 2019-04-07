//
//  Door.swift
//  DuneTraveller
//
//  Created by Bret Williams on 12/31/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class Door: SKSpriteNode {

    var isOpen: Bool = false
    var isLocked: Bool = true

    init() {
        
        
        let texture = SKTexture(pixelImageNamed: "door1")
        super.init(texture: texture, color: .white, size: texture.size())
        zPosition = 40
        
        physicsBody = SKPhysicsBody(rectangleOf: texture.size())
        physicsBody?.isDynamic = false
        physicsBody?.friction = 0
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 1
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = BodyType.door.rawValue
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func openDoor() {
        
        if let openAnimation:SKAction = SKAction(named: "OpenDoor") {
        
     //       var wait:SKAction = SKAction()
     //       wait = SKAction.wait(forDuration: 5)
            
            let finish:SKAction = SKAction.run {
                print("removing")
                self.userData?.removeAllObjects()
            //    self.removeFromParent()
                self.physicsBody?.categoryBitMask = BodyType.none.rawValue
                self.zPosition = -100
                
                
                
            }
            
            self.run(SKAction.sequence([openAnimation, finish]))
            
        }
        
    }
    
}
