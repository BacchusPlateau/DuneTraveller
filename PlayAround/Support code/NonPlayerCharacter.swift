//
//  NonPlayerCharacter.swift
//  PlayAround
//
//  Created by Bret Williams on 1/13/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class NonPlayerCharacter: SKSpriteNode {
    
    var frontName:String = ""
    var backName:String = ""
    var leftName:String = ""
    var rightName:String = ""
    var baseFrame:String = ""
    
    var isWalking:Bool = false
    var initialSpeechArray = [String]()
    var reminderSpeechArray = [String]()
    var alreadyContacted:Bool = false
    
    var currentSpeech:String = ""
    var speechIcon:String = ""
    var infoTime:TimeInterval = 1
    
    var isCollidableWithItems:Bool = false
    var isCollidableWithPlayer:Bool = false
    
    func setUpWithDict( theDict : [String : Any ]) {
 
        
        for (key, value) in theDict  {
            if(key == "Front") {
                frontName = value as! String
                
            }
            else if(key == "Back") {
                backName = value as! String
                
            }
            else if(key == "Left") {
                leftName = value as! String
                
            }
            else if(key == "Right") {
                rightName = value as! String
                
            }
            else if(key == "InitialSpeech") {
                if let theValue = value as? [String] {
                    initialSpeechArray = theValue
                }
                else if let theValue = value as? String {
                    initialSpeechArray.append(theValue)
                }
            }
            else if(key == "ReminderSpeech") {
                if let theValue = value as? [String] {
                    reminderSpeechArray = theValue
                }
                else if let theValue = value as? String {
                    reminderSpeechArray.append(theValue)
                }
            }
            else if(key == "Icon") {
                if let theValue = value as? String {
                    speechIcon = theValue
                }
            } else if(key == "CollidableWithItems") {
                if let theValue = value as? Bool {
                    isCollidableWithItems = theValue
                }
            } else if(key == "CollidableWithPlayer") {
                if let theValue = value as? Bool {
                    isCollidableWithPlayer = theValue
                }
            } else if(key == "BaseImage") {
                if let theValue = value as? String {
                    baseFrame = theValue
                }
            } else if(key == "Time") {
                if let theValue = value as? TimeInterval {
                    infoTime = theValue
                }
            }
            
        } //end for
        
        let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: self.frame.size.width / 3, center:CGPoint.zero)
        self.physicsBody = body
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        
        
        self.physicsBody?.categoryBitMask = BodyType.npc.rawValue
        self.physicsBody?.contactTestBitMask = BodyType.player.rawValue
        
        if (isCollidableWithPlayer && isCollidableWithItems) {
            
            self.physicsBody?.collisionBitMask = BodyType.item.rawValue | BodyType.player.rawValue | BodyType.npc.rawValue | BodyType.attackArea.rawValue
            
            print ("NPC is colliding with items and player")
            
        } else if (!isCollidableWithPlayer && isCollidableWithItems) {
            
            self.physicsBody?.collisionBitMask = BodyType.item.rawValue | BodyType.npc.rawValue | BodyType.attackArea.rawValue
            
            print ("NPC is colliding with items")
            
        } else if (isCollidableWithPlayer && !isCollidableWithItems) {
            
            self.physicsBody?.collisionBitMask = BodyType.player.rawValue | BodyType.npc.rawValue | BodyType.attackArea.rawValue
            
            print ("NPC is colliding with player")
            
        } else {
            self.physicsBody?.collisionBitMask = 0
        }
        
        walkRandom()
    }
    
    func walkRandom() {
        
        let waitTime = arc4random_uniform(3)
        let wait:SKAction = SKAction.wait(forDuration: TimeInterval(waitTime))
        let randomNum = arc4random_uniform(4)
        let endMove:SKAction = SKAction.run {
            self.walkRandom()
        }
        
        switch randomNum {
        case 0:
            self.run(SKAction(named:rightName)!)
            let move:SKAction = SKAction.moveBy(x: 50, y: 0, duration: 1)
            self.run(SKAction.sequence([move,wait,endMove]))
        case 1:
            self.run(SKAction(named:backName)!)
            let move:SKAction = SKAction.moveBy(x: 0, y: 50, duration: 1)
            self.run(SKAction.sequence([move,wait,endMove]))
        case 2:
            self.run(SKAction(named:frontName)!)
            let move:SKAction = SKAction.moveBy(x: 0, y: -50, duration: 1)
            self.run(SKAction.sequence([move,wait,endMove]))
        case 3:
            self.run(SKAction(named:leftName)!)
            let move:SKAction = SKAction.moveBy(x: -50, y: 0, duration: 1)
            self.run(SKAction.sequence([move,wait,endMove]))
        default:
            self.run(SKAction(named:rightName)!)
            let move:SKAction = SKAction.moveBy(x: 50, y: 0, duration: 1)
            self.run(SKAction.sequence([move,wait,endMove]))
        }
        
        
    }
    
    func contactPlayer() {
        isWalking = false
        self.removeAllActions()
        self.texture = SKTexture(imageNamed: baseFrame)
        if(!alreadyContacted) {
            alreadyContacted = true
        }
        
    }
    
    func endContactPlayer () {
        
        if(!isWalking) {
            
            isWalking = true;
            walkRandom()
          
        }
        
    }
    
    func speak() -> String {
        
        if(currentSpeech == "") {
            
            if (!alreadyContacted) {
                let randomLine:UInt32 = arc4random_uniform( UInt32 ( initialSpeechArray.count ))
                
                currentSpeech = initialSpeechArray[Int (randomLine)]
            } else {
                let randomLine:UInt32 = arc4random_uniform( UInt32 ( reminderSpeechArray.count ))
                
                currentSpeech = reminderSpeechArray[Int (randomLine)]
            }
            
            let wait:SKAction = SKAction.wait(forDuration: 3)
            let run:SKAction = SKAction.run {
                self.currentSpeech = ""
            }
            
            self.run(SKAction.sequence([wait,run]))
            
        }
        
        return currentSpeech
        
    }
    
}
