//
//  EnemyAttackArea.swift
//  PlayAround
//
//  Created by Bret Williams on 4/1/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit


class EnemyAttackArea : SKSpriteNode {
    
    var animationName:String = ""
    var scaleSize:CGFloat = 2
    var scaleTime:TimeInterval = 1
    var damage:Int = 1
    var removeOnContact:Bool = false
    
    func setUp() {
        
        let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: self.frame.size.width / 2, center:CGPoint.zero)
        self.physicsBody = body
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        
        self.physicsBody?.categoryBitMask = BodyType.enemyAttackArea.rawValue
        self.physicsBody?.collisionBitMask = BodyType.player.rawValue | BodyType.projectile.rawValue
        self.physicsBody?.contactTestBitMask = BodyType.player.rawValue | BodyType.attackArea.rawValue
        
        if (animationName != "") {
            if let theAnimation:SKAction = SKAction(named: animationName) {
                self.run(theAnimation)
            }
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
