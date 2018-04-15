//
//  Projectile.swift
//  PlayAround
//
//  Created by Bret Williams on 3/17/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class Projectile: SKSpriteNode {
    
    var travelTime:TimeInterval = 1
    var rotationTime:TimeInterval = 0
    var distance:CGFloat = 0
    var removeAfterThrow:Bool = true
    var offset:CGFloat = 0
    var contactAnimation:String = ""
    var animationName:String = ""
    var isFromEnemy:Bool = false
    var impactWithItems:Bool = true
    var damage:Int = 1
    
    func setUpWithDict(theDict:[String:Any]) {
        
        let body:SKPhysicsBody = SKPhysicsBody(texture: self.texture!, size: (self.texture?.size())!)
        self.physicsBody = body
        
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        
        
        for (key,value) in theDict {
            
            switch key {
            case "TravelTime":
                if(value is TimeInterval) {
                    travelTime = value as! TimeInterval
                }
            case "RotationTime":
                if(value is TimeInterval) {
                    rotationTime = value as! TimeInterval
                }
            case "Distance":
                if(value is CGFloat) {
                    distance = value as! CGFloat
                }
            case "Remove":
                if(value is Bool) {
                    removeAfterThrow = value as! Bool
                }
            case "ZPosition":
                if(value is CGFloat) {
                    self.zPosition = value as! CGFloat
                }
            case "Offset":
                if(value is CGFloat) {
                    offset = value as! CGFloat
                }
            case "ContactAnimation":
                if(value is String) {
                    contactAnimation = value as! String
                }
            case "Damage":
                if(value is Int) {
                    damage = value as! Int
                }
            case "ImpactWithItems":
                if(value is Bool) {
                    impactWithItems = value as! Bool
                }
            case "Animation":
                if(value is String) {
                    animationName = value as! String
                    
                    if (animationName != "") {
                        
                        if let animation:SKAction = SKAction(named: animationName) {
                            self.run(animation)
                        }
                        
                    }
                }
            default:
                continue
            }
        }
        
        if (!isFromEnemy) {
            
            //thrown by player
            
            self.physicsBody?.categoryBitMask = BodyType.projectile.rawValue
            
            if (!impactWithItems) {
                
                self.physicsBody?.collisionBitMask = BodyType.enemy.rawValue | BodyType.enemyAttackArea.rawValue
                self.physicsBody?.contactTestBitMask = BodyType.enemy.rawValue | BodyType.player.rawValue
                
            } else {
                
                self.physicsBody?.collisionBitMask = BodyType.item.rawValue | BodyType.enemy.rawValue | BodyType.enemyAttackArea.rawValue
                self.physicsBody?.contactTestBitMask = BodyType.enemy.rawValue | BodyType.player.rawValue | BodyType.item.rawValue
                
            }
            
            
        } else {
            
            //thrown by enemy
            self.physicsBody?.categoryBitMask = BodyType.enemyProjectile.rawValue
            self.physicsBody?.contactTestBitMask = BodyType.player.rawValue
            
            if (!impactWithItems) {
    
                self.physicsBody?.collisionBitMask = BodyType.player.rawValue
                
            } else {
                
                self.physicsBody?.collisionBitMask = BodyType.player.rawValue | BodyType.item.rawValue
                
            }
            
        }
        
    }
    
}
