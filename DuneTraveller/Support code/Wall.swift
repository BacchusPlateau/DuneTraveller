//
//  Wall.swift
//  DuneTraveller
//
//  Created by Bret Williams on 12/28/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class Wall : SKSpriteNode {
    
    init() {
        
        let texture = SKTexture(pixelImageNamed: "wall_four_panel")
        super.init(texture: texture, color: .white, size: texture.size())
     
        zPosition = 50
        physicsBody = SKPhysicsBody(rectangleOf: texture.size())
        physicsBody?.isDynamic = false
        physicsBody?.friction = 0
        physicsBody?.restitution = 1
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = BodyType.wall.rawValue
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
