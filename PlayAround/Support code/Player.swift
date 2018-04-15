//
//  Player.swift
//  PlayAround
//
//  Created by Bret Williams on 3/5/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class Player : SKSpriteNode {

    var frontWalk: String = ""
    var frontIdle: String = ""
    var frontMelee: String = ""
    var frontRanged: String = ""
    var frontHurt: String = ""
    var frontDying: String = ""
    
    var backWalk: String = ""
    var backIdle: String = ""
    var backMelee: String = ""
    var backRanged: String = ""
    var backHurt: String = ""
    var backDying: String = ""
    
    var leftWalk: String = ""
    var leftIdle: String = ""
    var leftMelee: String = ""
    var leftRanged: String = ""
    var leftHurt: String = ""
    var leftDying: String = ""
    
    var rightWalk: String = ""
    var rightIdle: String = ""
    var rightMelee: String = ""
    var rightRanged: String = ""
    var rightHurt:String = ""
    var rightDying: String = ""
    
    var meleeAnimationFXName:String = "Attacking"
    var meleeScaleSize:CGFloat = 2
    var meleeAnimationSize:CGSize = CGSize(width: 100, height:100)
    var meleeDamage:Int = 1
    var meleeTimeBetweenUse:TimeInterval = 0
    
    var walkSpeedOnPath:TimeInterval = 0.5
    var walkSpeed:CGFloat = 2.0
    
    var immunity:TimeInterval = 1
    var armor:Int = 20
    var health:Int = 20

    var currentProjectile:String = ""
    var defaultProjectile:String = ""
    
    var canBeDamaged:Bool = true
    var isDead:Bool = false
    
    func setUpWithDict( theDict: [String:Any]) {
        
        for (key,value) in theDict {
            
            switch key {
            case "Animation":
                if (value is [String:Any]) {
                    
                    sortAnimationDict(theDict: value as! [String:Any])
                    
                }
            case "Melee":
                if (value is [String:Any]) {
                    
                    sortMeleeDict(theDict: value as! [String:Any])
                    
                }
            case "Stats":
                if (value is [String:Any]) {
                    
                    sortStatsDict(theDict: value as! [String:Any])
                    
                }
            case "Ranged":
                if (value is [String:Any]) {
                    
                    sortRangedDict(theDict: value as! [String:Any])
                    
                }
            default:
                continue
            }
        }
        
    }
    
    func sortStatsDict(theDict:[String:Any]) {
        
        for (key, value) in theDict {
            
            switch key {
                
            case "Speed":
                if (value is CGFloat) {
                    
                    walkSpeed = value as! CGFloat
                }
            case "PathSpeed":
                if (value is TimeInterval) {
                    
                    walkSpeedOnPath = value as! TimeInterval
                }
            case "Armor":
                if (value is Int) {
                    
                    armor = value as! Int
                    
                }
            case "Immunity":
                if (value is CGFloat) {
                    
                    meleeScaleSize = value as! CGFloat
                    
                }
            case "Health":
                if (value is Int) {
                    
                    health = value as! Int
                    
                }
                
            default:
                continue
            }
        }
        
    }
        
    func sortAnimationDict(theDict:[String:Any]) {
        
        for (key,value) in theDict {
            
            switch key {
                
            case "Back":
                if let backDict:[String:Any] = value as? [String:Any] {
                    
                    for (key, value) in backDict {
                        
                        switch key {
                            
                        case "Walk":
                            backWalk = value as! String
                        case "Idle":
                            backIdle = value as! String
                        case "Melee":
                            backMelee = value as! String
                        case "Ranged":
                            backRanged = value as! String
                        case "Hurt":
                            backHurt = value as! String
                        case "Dying":
                            backDying = value as! String
                        default:
                            continue
                            
                        }
                    }
                }
            case "Front":
                if let backDict:[String:Any] = value as? [String:Any] {
                    
                    for (key, value) in backDict {
                        
                        switch key {
                            
                        case "Walk":
                            frontWalk = value as! String
                        case "Idle":
                            frontIdle = value as! String
                        case "Melee":
                            frontMelee = value as! String
                        case "Ranged":
                            frontRanged = value as! String
                        case "Hurt":
                            frontHurt = value as! String
                        case "Dying":
                            frontDying = value as! String
                        default:
                            continue
                            
                        }
                    }
                }
            case "Left":
                if let backDict:[String:Any] = value as? [String:Any] {
                    
                    for (key, value) in backDict {
                        
                        switch key {
                            
                        case "Walk":
                            leftWalk = value as! String
                        case "Idle":
                            leftIdle = value as! String
                        case "Melee":
                            leftMelee = value as! String
                        case "Ranged":
                            leftRanged = value as! String
                        case "Hurt":
                            leftHurt = value as! String
                        case "Dying":
                            leftDying = value as! String
                        default:
                            continue
                            
                        }
                    }
                }
            case "Right":
                if let backDict:[String:Any] = value as? [String:Any] {
                    
                    for (key, value) in backDict {
                        
                        switch key {
                            
                        case "Walk":
                            rightWalk = value as! String
                        case "Idle":
                            rightIdle = value as! String
                        case "Melee":
                            rightMelee = value as! String
                        case "Ranged":
                            rightRanged = value as! String
                        case "Hurt":
                            rightHurt = value as! String
                        case "Dying":
                            rightDying = value as! String
                        default:
                            continue
                            
                        }
                    }
                }
            default:
                continue
            }
            
        }
        
    }
    
    func sortRangedDict(theDict:[String:Any]) {
        
        for (key, value) in theDict {
            
            switch key {
                
            case "Projectile":
                if (value is String) {
                    
                    currentProjectile = value as! String
                    defaultProjectile = currentProjectile
                }
            default:
                continue
            }
        }
    }
    
    
    
    func sortMeleeDict(theDict:[String:Any]) {
        
        for (key, value) in theDict {
            
            switch key {
                
            case "Damage":
                if (value is Int) {
                    
                    meleeDamage = value as! Int
                }
            case "Size":
                if (value is String) {
                    
                    meleeAnimationSize = CGSizeFromString(value as! String)
                }
            case "Animation":
                if (value is String) {
                    
                    meleeAnimationFXName = value as! String
                }
            case "ScaleTo":
                if (value is CGFloat) {
                    
                    meleeScaleSize = value as! CGFloat
                    
                }
            case "TimeBetweenUse":
                if (value is TimeInterval) {
                    
                    meleeTimeBetweenUse = value as! TimeInterval
                }
                
            default:
                continue
            }
        }
    }
        
    func damaged() {
        
        canBeDamaged = false
        
        let wait:SKAction = SKAction.wait(forDuration: immunity)
        let finish:SKAction = SKAction.run {
            self.canBeDamaged = true
        }
            
        let seq:SKAction = SKAction.sequence([wait, finish])
        self.run(seq)
        
    }



}
