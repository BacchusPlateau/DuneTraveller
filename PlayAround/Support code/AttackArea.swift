//
//  AttackArea.swift
//  PlayAround
//
//  Created by Bret Williams on 12/31/17.
//  Copyright © 2017 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class AttackArea : SKSpriteNode {
    
    var animationName:String = ""
    var scaleSize:CGFloat = 2
    var damage:Int = 1
    
    func setUp() {
        
        let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: self.frame.size.width / 2, center:CGPoint.zero)
        self.physicsBody = body
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        
        self.physicsBody?.categoryBitMask = BodyType.attackArea.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = BodyType.enemy.rawValue | BodyType.enemyAttackArea.rawValue

        upAndAway()
        
        if (animationName != "") {
            self.run(SKAction(named: animationName)!)
        }
    }
    
    func upAndAway() {
        
        let grow:SKAction = SKAction.scale(by: scaleSize, duration: 0.5)
        let finish:SKAction = SKAction.run {
            
            self.removeFromParent()
            
        }
        
        let seq:SKAction = SKAction.sequence([grow,finish])
        self.run(seq)
        
        
    }
}
