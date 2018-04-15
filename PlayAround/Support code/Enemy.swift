//
//  Enemy.swift
//  PlayAround
//
//  Created by Bret Williams on 4/1/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

enum MoveType: Int {
    
    case actions, follow, random, none
}


class Enemy : SKSpriteNode {

    var defaults:UserDefaults = UserDefaults.standard
    var isDead:Bool = false
    
    //movement
    var movementType:MoveType = .none
    var moveIfPlayerWithin:CGFloat = -1  //determines whether to pause enemy if player goes out of range
    var allowMovement:Bool = false
    var movementActions = [String]()
    
    var waitTimeForRandomWalking:TimeInterval = -1
    var randomWaitTimeRange:UInt32 = 3
    var walkTime:TimeInterval = 1
    var walkDistance:CGFloat = 50
    var walkSpeed:CGFloat = 1
    
    var facing:Facing = .none
    
    //ranged attack
    var hasRangedAttack:Bool = false
    var fireIfPlayerWIthin:CGFloat = -1
    var allowRangedAttack:Bool = false
    var projectileName:String = ""
    var timeBetweenRangedAttacks:TimeInterval = 1
    var projectileDict = [String:Any]()
    var justDidRangedAttack:Bool = false
    var projectileImage:String = ""
    
    //melee attack
    var hasMeleeAttack:Bool = false
    var meleeIfPlayerWithin:CGFloat = -1  //radius for melee
    var meleeDamage:Int = 0
    var allowMeleeAttack:Bool = true
    var contactDamage:Int = 0
    
    var meleeSize:CGSize = CGSize(width:100, height:100)
    var meleeScaleTo:CGFloat = 2
    var meleeScaleTime:TimeInterval = 1
    var meleeAnimation:String = ""
    var meleeTimeBetweenUse:TimeInterval = 1
    var justDidMeleeAttack:Bool = false
    var meleeRemoveOnContact:Bool = false
    
    //stats
    var health:Int = 1
    var initialHealth:Int = 1
    var immunityAfterDamage:TimeInterval = 1
    var immunityWhenIdle:Bool = false
    var isImmune:Bool = false
    var showHealthLabel:Bool = true
    
    //animation
    var frontWalk:String = ""
    var frontIdle:String = ""
    var frontMelee:String = ""
    var frontRanged:String = ""
    var frontHurt:String = ""
    
    var backWalk:String = ""
    var backIdle:String = ""
    var backMelee:String = ""
    var backRanged:String = ""
    var backHurt:String = ""
    
    var leftWalk:String = ""
    var leftIdle:String = ""
    var leftMelee:String = ""
    var leftRanged:String = ""
    var leftHurt:String = ""
    
    var rightWalk:String = ""
    var rightIdle:String = ""
    var rightMelee:String = ""
    var rightRanged:String = ""
    var rightHurt:String = ""
    
    var rightDying:String = ""
    var leftDying:String = ""
    var backDying:String = ""
    var frontDying:String = ""

    var rewardDictionary = [String:Any]()
    var saveRewardDictionary = [String:Any]()
    var removeDictionary = [String:Any]()
    
    var neverRewardAgain:Bool = false
    var neverShowAgain:Bool = false
    var deleteBody:Bool = false
    var deleteFromLevel:Bool = true
    var respawnAfter:TimeInterval = -1
    var respawnWithRewards:Bool = true
    
    var hasIdleAnimation:Bool = false
    
    func setUpEnemy(theDict:[String:Any]) {
        
        print(self.name!)
        
        self.physicsBody?.categoryBitMask = BodyType.enemy.rawValue
        self.physicsBody?.collisionBitMask = BodyType.player.rawValue | BodyType.item.rawValue | BodyType.projectile.rawValue |
            BodyType.enemy.rawValue | BodyType.npc.rawValue
        self.physicsBody?.contactTestBitMask = BodyType.player.rawValue | BodyType.projectile.rawValue | BodyType.attackArea.rawValue
        
        for (key,value) in theDict {
            
            switch key {
            case "Movement":
                
                if (value is [String:Any]) {
                    
                    sortMovementDict(theDict: value as! [String:Any])
                    
                }
                
            case "Animation":
                
                if (value is [String:Any]) {
                    
                    sortAnimationDict(theDict: value as! [String:Any])
                }
                
            case "Melee":
                
                if (value is [String:Any]) {
                    
                    sortMeleeDict(theDict: value as! [String:Any])
                }
                
            case "Ranged":
                
                if (value is [String:Any])  {
                    sortRangedDict(theDict: value as! [String:Any])
                }
                
            case "Stats":
                
                if (value is [String:Any])  {
                    sortStatsDict(theDict: value as! [String:Any])
                }
                
            case "Rewards":
                
                if (value is [String:Any])  {
                    
                    rewardDictionary =  value as! [String:Any]
                    saveRewardDictionary = value as! [String:Any]
                
                }
                
            case "RemoveWhen":
                
                if (value is [String:Any])  {
                    removeDictionary = value as! [String:Any]
                }
                
            case "AfterDefeat":
                
                if (value is [String:Any])  {
                    sortAfterDefeat(theDict: value as! [String:Any])
                }
                
            default:
                continue
            }
        }
        
        checkRemoveRequirements()
        postSetUp()
        
        if (neverRewardAgain) {
            
            if (defaults.bool(forKey: self.name! + "AlreadyAwarded")) {
                rewardDictionary.removeAll()
            }
            
        }
        
        if (neverShowAgain) {
            
            if (defaults.bool(forKey: self.name! + "NeverShowAgain")) {
                self.removeFromParent() 
            }
        }
        
    }
    
    func postSetUp() {
        
        if (moveIfPlayerWithin == -1 && movementType == .actions) {
            
            allowMovement = true
            
            //start movement from actions array
            startMovementFromArray()
            
        }
        
        
        
    }
    
    func update(playerPos:CGPoint) {
        
        if (!isDead) {
            
            if (movementType == .actions) {
                
                if (allowMovement) {
                    
                    if (self.action(forKey: "Movement") == nil && self.action(forKey: "Hurt") == nil) {
                        
                        startMovementFromArray()
                        
                    } else if (hasIdleAnimation) {
                        
                        if(self.action(forKey: "Movement") == nil
                            && self.action(forKey: "Hurt") == nil
                            && self.action(forKey: "Idle") == nil) {
                            
                            runIdleAnimation(playerPos: playerPos)
                            
                        }
                        
                    }
                    
                }
                
            } else if (movementType == .follow) {
                
                if (allowMovement) {
                    
                    if (self.action(forKey: "Hurt") == nil) {
                        
                        orientEnemy(playerPos:playerPos)
                        moveEnemy()
                        animateWalk()
                        
                    } else if (hasIdleAnimation) {
                        
                        if(self.action(forKey: "Hurt") == nil
                            && self.action(forKey: "Idle") == nil) {
                            
                            self.removeAction(forKey: "WalkAnimation")
                            runIdleAnimation(playerPos: playerPos)
                            
                        }
                        
                    }
                    
                }
                
            } else if (movementType == .none) {
                
                
                
            } else if (movementType == .random) {
                
                if (allowMovement) {
                    
                    if (self.action(forKey: "Movement") == nil
                        && self.action(forKey: "Hurt") == nil
                        && self.action(forKey: "Attack") == nil) {
           
                        walkRandom()
                        
                    }
                    
                } else if (hasIdleAnimation) {
                    
                    if(self.action(forKey: "Hurt") == nil
                        && self.action(forKey: "Idle") == nil) {
                        
                        stopWalking()
                        runIdleAnimation(playerPos: playerPos)
                        
                    }
                    
                }
                
            }

            if (!justDidMeleeAttack && allowMeleeAttack) {
                
                orientEnemy(playerPos: playerPos)
                meleeAttack()
                
            }
            
            if (!justDidRangedAttack && allowRangedAttack) {
                
                orientEnemy(playerPos: playerPos)
                rangedAttack()
                
            }
        }
        
    }
    
    func checkRemoveRequirements() {
    
        for (key,value) in removeDictionary {
            
            if (value is Int) {
                if (defaults.integer(forKey: key) >= value as! Int) {
                    
                    self.removeFromParent()
                    
                }
            }
        }
        
    }
    
    func stopWalking() {
        
        if (self.movementType != .actions) {
            
            self.removeAction(forKey: "Movement")
            self.removeAction(forKey: "WalkAnimation")
            
        }
        
    }
    
    func afterDefeat() {
        
        let saveBody:SKPhysicsBody = self.physicsBody!
        
        if (deleteBody) {
            
            self.physicsBody = nil
            
        } else if (deleteFromLevel && respawnAfter == -1) {
            
            self.removeFromParent()
            
        } else if (deleteFromLevel && respawnAfter > 0) {
            
            self.physicsBody = nil
            self.isHidden = true
            
        }
        
        if (neverShowAgain) {
            
            defaults.set(true, forKey: self.name! + "NeverShowAgain")
            
        }
        
        if (respawnAfter > 0) {
            
            let wait:SKAction = SKAction.wait(forDuration: respawnAfter)
            let finish:SKAction = SKAction.run {
                
                self.physicsBody = saveBody
                self.respawn()
                
            }
            let seq:SKAction = SKAction.sequence([wait, finish])
            self.run(seq)
            
        }
        
    }
    
    func respawn() {
        
        self.isHidden = false
        isDead = false
        isImmune = false
        
        health = initialHealth
        
        if (respawnWithRewards) {
            
            rewardDictionary = saveRewardDictionary
            
        }
        
        self.runIdleAnimation(playerPos: CGPoint.zero)
        
    }
    
    func animateWalk() {
        
        if (self.action(forKey: "Attack") == nil && self.action(forKey: "WalkAnimation") == nil) {
            
            var theAnimation:String = ""
            
            switch facing {
            case .right:
                theAnimation = rightWalk
            case .left:
                theAnimation = leftWalk
            case .back:
                theAnimation = backWalk
            case .front:
                theAnimation = frontWalk
            case .none:
                break
            }
            
            if (theAnimation != "") {
                
                self.removeAction(forKey: "Idle")

                if let walkAnimation:SKAction = SKAction(named:theAnimation) {
                    
                    self.run(walkAnimation, withKey: "WalkAnination")
                    
                }

            }
            
        }
        
    }
    
    func moveEnemy() {
        
        switch facing {
        case .right:
            self.position = CGPoint(x: self.position.x + walkSpeed, y: self.position.y)
        case .left:
            self.position = CGPoint(x: self.position.x - walkSpeed, y: self.position.y)
        case .back:
            self.position = CGPoint(x: self.position.x, y: self.position.y + walkSpeed)
        case .front:
            self.position = CGPoint(x: self.position.x, y: self.position.y - walkSpeed)
        case .none:
            break
        }
        
    }
    
    func orientEnemy(playerPos: CGPoint) {
        
        if (abs(playerPos.x - self.position.x) > (abs(playerPos.y - self.position.y))) {
            
            //greater movement on the X
            
            if (playerPos.x > self.position.x) {
                
                self.facing = .right
                
            } else {
                
                self.facing = .left
                
            }
            
        } else {
            
            //greater movement on the Y
         
            if (playerPos.y > self.position.y) {
                
                self.facing = .back
                
            } else {
                
                self.facing = .front
                
            }
        }
        
        
    }
    
    func walkRandom() {
        
        self.removeAction(forKey: "Idle")
        var wait:SKAction = SKAction()
        
        if (waitTimeForRandomWalking > -1)  {
            
            wait = SKAction.wait(forDuration: waitTimeForRandomWalking)
            
        } else {
            
            let waitTime = arc4random_uniform(randomWaitTimeRange)
            wait = SKAction.wait(forDuration: TimeInterval(waitTime))
            
        }
        
        let endMove:SKAction = SKAction.run {
            
            self.removeAction(forKey: "WalkAnimation")
            
        }
        
      //  print("walkDistance = " + String(format: "%.2f",walkDistance))
      //  print("walkTime = " + String(walkTime))
        
        let randomNum = arc4random_uniform(4)
        //print (randomNum)
        switch randomNum {
        case 0:
            
            if let walk = SKAction(named: frontWalk) {
       //         print ("frontWalk = " + frontWalk)
                let repeatWalk:SKAction = SKAction.repeatForever(walk)
                self.run(repeatWalk, withKey: "WalkAnimation")
            }
            
            let move:SKAction = SKAction.moveBy(x: 0, y: -walkDistance, duration: walkTime)
            self.run(SKAction.sequence([ move, endMove, wait ]), withKey: "Movement")
        case 1:
            
            if let walk = SKAction(named: backWalk) {
       //         print ("backWalk = " + backWalk)
                let repeatWalk:SKAction = SKAction.repeatForever(walk)
                self.run(repeatWalk, withKey: "WalkAnimation")
            }
            
            let move:SKAction = SKAction.moveBy(x: 0, y: walkDistance, duration: walkTime)
            self.run(SKAction.sequence([ move, endMove, wait ]), withKey: "Movement")
        case 2:
            
            if let walk = SKAction(named: leftWalk) {
       //         print("leftWalk = " + leftWalk)
                let repeatWalk:SKAction = SKAction.repeatForever(walk)
                self.run(repeatWalk, withKey: "WalkAnimation")
            }
            
            let move:SKAction = SKAction.moveBy(x: -walkDistance, y:0, duration: walkTime)
            self.run(SKAction.sequence([ move, endMove, wait ]), withKey: "Movement")
        case 3:
            
            if let walk = SKAction(named: rightWalk) {
       //         print("rightWalk = " + rightWalk)
                let repeatWalk:SKAction = SKAction.repeatForever(walk)
                self.run(repeatWalk, withKey: "WalkAnimation")
            }
            
            let move:SKAction = SKAction.moveBy(x: walkDistance, y: 0, duration: walkTime)
            self.run(SKAction.sequence([ move, endMove, wait ]), withKey: "Movement")
        default:
            break
        }
        
    }
    
    func startMovementFromArray() {
        
        self.removeAction(forKey: "Idle")
        
        var actionArray = [SKAction]()
        
        for name in movementActions {
            
            if let someAction:SKAction = SKAction(named: name) {
                
                actionArray.append(someAction)
                
            }
        }
        
        let finishLoop:SKAction = SKAction.run {
            
            if (self.allowMovement == false)  {
                
                self.removeAction(forKey: "Movement")
            }
            
        }
        
        actionArray.append(finishLoop)
        
        let seq:SKAction = SKAction.sequence(actionArray)
        let loop:SKAction = SKAction.repeatForever(seq)
        
        self.run(loop, withKey: "Movement")
        
    }
    
    //MARK:  Sorting stuff
    
    func sortAnimationDict(theDict: [String:Any]) {
        
        for (key,value) in theDict {
        //    print ("key = " + key)
            switch key {
            case "Back":
                if let backDict:[String:Any] = value as? [String:Any] {
                    for (backKey, backValue) in backDict {
              //          print ("backKey = " + backKey)
              //          print ("backValue = " + (backValue as! String))
                        switch backKey {
                        case "Walk":
                            backWalk = backValue as! String
                        case "Idle":
                            backIdle = backValue as! String
                        case "Melee":
                            backMelee = backValue as! String
                        case "Ranged":
                            backRanged = backValue as! String
                        case "Hurt":
                            backHurt = backValue as! String
                        case "Dying":
                            backDying = backValue as! String
                        default:
                            continue
                        }
                    }
                }
            case "Front":
                if let frontDict:[String:Any] = value as? [String:Any] {
                    for (frontKey, frontValue) in frontDict {
                        switch frontKey {
                        case "Walk":
                            frontWalk = frontValue as! String
                        case "Idle":
                            frontIdle = frontValue as! String
                            hasIdleAnimation = true
                        case "Melee":
                            frontMelee = frontValue as! String
                        case "Ranged":
                            frontRanged = frontValue as! String
                        case "Hurt":
                            frontHurt = frontValue as! String
                        case "Dying":
                            frontDying = frontValue as! String
                        default:
                            continue
                        }
                    }
                }
            case "Left":
                if let leftDict:[String:Any] = value as? [String:Any] {
                    for (leftKey, leftValue) in leftDict {
                        switch leftKey {
                        case "Walk":
                            leftWalk = leftValue as! String
                        case "Idle":
                            leftIdle = leftValue as! String
                        case "Melee":
                            leftMelee = leftValue as! String
                        case "Ranged":
                            leftRanged = leftValue as! String
                        case "Hurt":
                            leftHurt = leftValue as! String
                        case "Dying":
                            leftDying = leftValue as! String
                        default:
                            continue
                        }
                    }
                }
            case "Right":
                if let rightDict:[String:Any] = value as? [String:Any] {
                    for (rightKey, rightValue) in rightDict {
                        switch  rightKey {
                        case "Walk":
                            rightWalk = rightValue as! String
                        case "Idle":
                            rightIdle = rightValue as! String
                        case "Melee":
                            rightMelee = rightValue as! String
                        case "Ranged":
                            rightRanged = rightValue as! String
                        case "Hurt":
                            rightHurt = rightValue as! String
                        case "Dying":
                            rightDying = rightValue as! String
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
    
    func sortRangedDict(theDict: [String:Any]) {
        
        hasRangedAttack = true
        
        for (key,value) in theDict {
            
            switch key {
            case "Projectile":
                if (value is String) {
                    getProjectileData(name: value as! String)
                }
            case "TimeBetweenUse":
                if (value is TimeInterval) {
                    timeBetweenRangedAttacks = value as! TimeInterval
                }
            case "Within":
                if (value is CGFloat) {
                    fireIfPlayerWIthin = value as! CGFloat
                }
            default:
                continue
            }
        }
    }
    
    func sortMeleeDict(theDict: [String:Any]) {
        
        hasMeleeAttack = true
        
        for (key,value) in theDict {
            
            switch key {
            case "Damage":
                if (value is Int) {
                    meleeDamage = value as! Int
                }
            case "Size":
                if (value is String) {
                    meleeSize = CGSizeFromString(value as! String)
                }
            case "ScaleTo":
                if (value is CGFloat) {
                    meleeScaleTo = value as! CGFloat
                }
            case "ScaleTime":
                if (value is TimeInterval) {
                    meleeScaleTime = value as! TimeInterval
                }
            case "Animation":
                if (value is String) {
                    meleeAnimation = value as! String
                }
            case "TimeBetweenUse":
                if (value is TimeInterval) {
                    meleeTimeBetweenUse = value as! TimeInterval
                }
            case "Within":
                if (value is CGFloat) {
                    meleeIfPlayerWithin = value as! CGFloat
                }
            case "RemoveOnContact":
                if (value is Bool) {
                    meleeRemoveOnContact = value as! Bool
                }
            default:
                continue
            }
            
        }
        
    }
    
    func sortStatsDict(theDict: [String:Any]) {
        
        for (key,value) in theDict {
            
            switch key {
            case "Damage":
                
                if (value is Int) {
                    
                    contactDamage = value as! Int
                    
                }
                
            case "Health":
                
                if (value is Int) {
                    
                    health = value as! Int
                    initialHealth = health
                    
                }
                
            case "Immunity":
                
                if (value is TimeInterval) {
                    
                    immunityAfterDamage = value as! TimeInterval

                }
                
            case "ImmunityWhenIdle":
                
                if (value is Bool) {
                    
                    immunityWhenIdle = value as! Bool
                    
                }
                
            case "ShowHealthWhenHit":
                
                if (value is Bool) {
                    
                    showHealthLabel = value as! Bool
                    
                }
            default:
                continue
            }
            
        }
        
    }
    
    func sortAfterDefeat(theDict: [String:Any]) {
    
        for (key,value) in theDict {
            
            switch key {
            case "NeverRewardAgain":
                if (value is Bool) {
                    neverRewardAgain = value as! Bool
                }
            case "NeverShowAgain":
                if (value is Bool) {
                    neverShowAgain = value as! Bool
                }
            case "DeleteFromLevel":
                if (value is Bool) {
                    deleteFromLevel = value as! Bool
                }
            case "DeleteBody":
                if (value is Bool) {
                    deleteBody = value as! Bool
                }
            case "RespawnWithRewards":
                if (value is Bool) {
                    respawnWithRewards = value as! Bool
                }
            case "RespawnAfter":
                if (value is TimeInterval) {
                    respawnAfter = value as! TimeInterval
                }
            default:
                continue
            }
            
        }
    
    }
    
    func sortMovementDict(theDict: [String:Any]) {
        
        for (key,value) in theDict {
            
            switch key {
            case "Actions":
                
                if let someArray:[String] = value as? [String] {
                    
                    movementActions = someArray
                    movementType = .actions
                }
                
            case "Within":
                
                if (value is CGFloat) {
                    
                    moveIfPlayerWithin = value as! CGFloat
                    
                }
                
            case "Speed":
                
                if (value is CGFloat) {
                    
                    walkSpeed = value as! CGFloat
                    
                }
                
            case "FollowPlayer":
                
                if (value is Bool) {
                    
                    if (value as! Bool == true) {
                        
                        movementType = .follow
                        
                    }
                }
                
            case "WalkRandomly":
                
                if (value is Bool) {
                    
                    if (value as! Bool == true) {
                        
                        movementType = .random
                        
                    }
                }
            case "WaitTime":
                
                if (value is TimeInterval) {
                    
                    waitTimeForRandomWalking = value as! TimeInterval
                }
                
            case "WalkTime":
                
                if (value is TimeInterval) {
                    
                    walkTime = value as! TimeInterval
                    
                }
                
            case "WalkDistance":
                
                if (value is CGFloat) {
                    
                    walkDistance = value as! CGFloat
                }
                
            case "RandomWaitTime":
                
                if (value is UInt32) {
                    
                    randomWaitTimeRange = value as! UInt32
                }
                
            default:
                continue
            }
        }
    }
    
    func getProjectileData(name:String) {
        print("get projectile data for:" + name)
        let path = Bundle.main.path(forResource:"GameData", ofType: "plist")
        let dict:NSDictionary = NSDictionary(contentsOfFile: path!)!
        
        if (dict.object(forKey: "Projectiles") != nil) {
            
            if let projDict:[String:Any] = dict.object(forKey: "Projectiles") as? [String:Any] {
           //     print(projDict)
                for (key,value) in projDict {
                 //   print("Key = " + key)
                    if (key == name) {
                        
                        if (value is [String:Any]) {
                            
                            projectileDict = value as! [String:Any]
                       //     print("projectileDict")
                       //     print(projectileDict)
                            for (projKey, projValue) in projectileDict {
                                
                                switch projKey {
                                case "Image":
                                    if (projValue is String) {
                                        projectileImage = projValue as! String
                                    }
                                default:
                                    continue
                                }
                                
                            } //for projkey,projvalue
                            
                        } //if value is [String:Any]
                        
                        break
                        
                    } //if key==name
                    
                } //for key,value
                
                
                
            } //if let
            
        } //if dict.object
        
    }
    
    func showHurtAnimation() {
        
        var animationName:String = ""
        
        switch facing {
        case .right:
            animationName = rightHurt
        case .left:
            animationName = leftHurt
        case .back:
            animationName = backHurt
        case .front, .none:
            animationName = frontHurt
        }
        
        if (animationName != "")  {
            
            if let hurtAnimation:SKAction = SKAction(named: animationName) {
                
                stopWalking()
                
                if (movementType == .actions) {
                    
                    if (self.action(forKey: "Movement") != nil) {
                        
                        self.action(forKey: "Movement")?.speed = 0
                        
                    }
                }
                
                let finish:SKAction = SKAction.run {
                    
                    if (self.movementType == .actions) {
                        
                        if (self.action(forKey: "Movement") != nil) {
                            
                            self.action(forKey: "Movement")?.speed = 1
                            
                        }
                    }
                    
                }
                
                let seq:SKAction = SKAction.sequence([hurtAnimation, finish])
                self.run(seq, withKey: "Hurt")
                
            }
            
        }
    }
    
    func runIdleAnimation(playerPos:CGPoint) {
        
        if (self.action(forKey: "Attack") == nil) {
            
            if (playerPos != CGPoint.zero)  {
                
                orientEnemy(playerPos: playerPos)
                
            }
            
            var animationName:String = ""
            
            switch facing {
            case .right:
                animationName = rightIdle
            case .left:
                animationName = leftIdle
            case .back:
                animationName = backIdle
            case .front, .none:
                animationName = frontIdle
            }
            
            if (animationName != "")  {
                
                if let idleAnimation:SKAction = SKAction(named: animationName) {
                    
                    self.run(idleAnimation, withKey: "Idle")
                }
            }
            
        }
        
    }
    
    func killOff() {
        
        allowMovement = false
        self.removeAllActions()
        
        var animationName:String = ""
        
        switch facing {
        case .right:
            animationName = rightDying
        case .left:
            animationName = leftDying
        case .back:
            animationName = backDying
        case .front, .none:
            animationName = frontDying
        }
        
        if (animationName != "")  {
            
            if let dyingAction:SKAction = SKAction(named: animationName) {
                
                stopWalking()
                
                let finish:SKAction = SKAction.run {
                    
                    self.afterDefeat()
                    
                }
                
                let seq:SKAction = SKAction.sequence([dyingAction, finish])
                self.run(seq)
                
            }
            
        } else {
            
            self.afterDefeat()
            
        }
        
    }
    
    func showHealth() {
        
        if (showHealthLabel) {
            
            let healthLabel:SKLabelNode = SKLabelNode(fontNamed: "Helvetica Neue")
            healthLabel.zPosition = self.zPosition + 1000
            self.addChild(healthLabel)
            healthLabel.position = CGPoint(x: 0, y: self.size.height / 2)
            healthLabel.fontSize = 25
            healthLabel.text = String(health)
            
            let move:SKAction = SKAction.moveBy(x: 0, y: 50, duration: 1)
            let fade:SKAction = SKAction.fadeOut(withDuration: 1)
            let moveAndFade:SKAction = SKAction.group([move, fade])
            let finish:SKAction = SKAction.run {
                healthLabel.removeFromParent()
            }
            let seq:SKAction = SKAction.sequence([moveAndFade, finish])
            healthLabel.run(seq)
            
        }
    }
    
    
    func rangedAttack() {
        
        justDidRangedAttack = true
        
        let wait:SKAction = SKAction.wait(forDuration: timeBetweenRangedAttacks)
        let finishWait:SKAction = SKAction.run {
            self.justDidRangedAttack = false
        }
        self.run(SKAction.sequence([ wait, finishWait ]))
        
        let newProjectile:Projectile = Projectile(imageNamed: projectileImage)
        newProjectile.isFromEnemy = true
        newProjectile.setUpWithDict(theDict: projectileDict)
        
        self.addChild(newProjectile)
        
        var moveAction:SKAction = SKAction()
        var theDistance:CGFloat = 0
        var animationName:String = ""
        
        if (newProjectile.distance > 0) {
            theDistance = newProjectile.distance
        } else {
            theDistance = 1000
        }
        
        switch facing {
        case .front:
            moveAction = SKAction.moveBy(x: 0, y: -theDistance, duration: newProjectile.travelTime)
            animationName = frontRanged
            newProjectile.position = CGPoint(x: newProjectile.position.x, y: newProjectile.position.y - newProjectile.offset)
        case .back:
            moveAction = SKAction.moveBy(x: 0, y: theDistance, duration: newProjectile.travelTime)
            animationName = backRanged
            newProjectile.position = CGPoint(x: newProjectile.position.x, y: newProjectile.position.y + (newProjectile.offset * 2))
        case .left:
            moveAction = SKAction.moveBy(x: -theDistance, y: 0, duration: newProjectile.travelTime)
            animationName = leftRanged
            newProjectile.position = CGPoint(x: newProjectile.position.x - newProjectile.offset, y: newProjectile.position.y)
        case .right:
            moveAction = SKAction.moveBy(x: theDistance, y: 0, duration: newProjectile.travelTime)
            animationName = rightRanged
            newProjectile.position = CGPoint(x: newProjectile.position.x + newProjectile.offset, y: newProjectile.position.y)
        case .none:
            break
        }
        
        moveAction.timingMode = .easeOut
        
        let finish:SKAction = SKAction.run {
            
            newProjectile.removeFromParent()
        }
        
        let seq:SKAction = SKAction.sequence([ moveAction, finish ])
        newProjectile.run(seq)
        
        //make it spin!
        if (newProjectile.rotationTime > 0) {
            
            let randomAddOn:UInt32 = arc4random_uniform(10)
            let addOn:CGFloat = CGFloat(randomAddOn / 10)
            let rotateAction:SKAction = SKAction.rotate(byAngle: 6.28319 + addOn, duration: newProjectile.rotationTime)
            let repeatRotate:SKAction = SKAction.repeat(rotateAction, count: Int(newProjectile.travelTime / newProjectile.rotationTime))
            
            newProjectile.run(repeatRotate)
            
        }
        
        //stop the actions movement...
        if (movementType == .actions) {
            
            if (self.action(forKey: "Movement") != nil) {
                
                self.action(forKey: "Movement")?.speed = 0
                
            }
        }
        
        if (animationName != "") {
            
            if let attackAnimation:SKAction = SKAction(named: animationName) {
                
                let finish:SKAction = SKAction.run {
                    
                    if (self.allowMovement) {
                        
                        if (self.movementType == .actions) {
                            
                            if (self.action(forKey: "Movement") != nil) {
                                
                                //return the movement actions after attack
                                self.action(forKey: "Movement")?.speed = 1
                                
                            } else if (self.movementType == .random) {
                                
                                self.walkRandom()
                                
                            } else if (self.hasIdleAnimation) {
                                
                                self.runIdleAnimation(playerPos: CGPoint.zero)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                let seq:SKAction = SKAction.sequence([ attackAnimation, finish ])
                self.run(seq, withKey:"Attack")
                
            }
            
        }
        
    }
    
    func damage(with amount:Int) {
        
        var proceedToDamage:Bool = true
        
        if (!allowMovement && immunityWhenIdle) {
            
            proceedToDamage = false
            
        }
        
        if (!isImmune && proceedToDamage) {
            
            showHurtAnimation()
            self.isImmune = true
            
            let wait:SKAction = SKAction.wait(forDuration: immunityAfterDamage)
            let finish:SKAction = SKAction.run {
                self.isImmune = false
            }
            
            let seq:SKAction = SKAction.sequence([wait, finish])
            self.run(seq)
            health -= amount
            
            if (health > 0) {

                showHealth()
                
            } else {
                
                if (!isDead) {
                    
                    isDead = true
                    
                    let waitToKill:SKAction = SKAction.wait(forDuration: 1/60)
                    let finishAndKill:SKAction = SKAction.run {
                        self.killOff()
                    }
                    
                    let seq:SKAction = SKAction.sequence([waitToKill, finishAndKill])
                    self.run(seq)
                    
                }
            }
            
        }
    }
    
    
    func meleeAttack() {
        
        justDidMeleeAttack = true
        
        let wait:SKAction = SKAction.wait(forDuration: meleeTimeBetweenUse)
        let finishWait:SKAction = SKAction.run {
            self.justDidMeleeAttack = false
        }
        self.run(SKAction.sequence([ wait, finishWait ]))
        
        //set up enemy attack area
        let newAttack:EnemyAttackArea = EnemyAttackArea(color:  SKColor.clear, size: meleeSize)
        
        newAttack.scaleSize = meleeScaleTo
        newAttack.scaleTime = meleeScaleTime
        newAttack.damage = meleeDamage
        newAttack.removeOnContact = meleeRemoveOnContact
        newAttack.animationName = meleeAnimation
        
        newAttack.setUp()
        self.addChild(newAttack)
        newAttack.zPosition = self.zPosition - 1
        newAttack.upAndAway()
        
        if (movementType == .actions) {
            
            if (self.action(forKey: "Movement") != nil) {
                self.action(forKey: "Movement")?.speed = 0
            }
        }
        
        var animationName:String = ""
        
        switch facing {
        case .front:
            animationName = frontMelee
        case .back:
            newAttack.xScale = -1
            newAttack.yScale = -1
            animationName = backMelee
        case .right:
            animationName = rightMelee
        case .left:
            newAttack.xScale = -1
            animationName = leftMelee
        default:
            break
        }
        
        if (animationName != "") {
            
            if let attackAnimation:SKAction = SKAction(named: animationName) {
                
                stopWalking()
                
                let finish:SKAction = SKAction.run {
                    
                    if (self.movementType == .actions) {
                        
                        if (self.action(forKey: "Movement") != nil) {
                            
                            self.action(forKey: "Movement")?.speed = 1
                        }
                    }
                }
                
                let seq:SKAction = SKAction.sequence([ attackAnimation, finish ])
                self.run(seq, withKey:"Attack")
                
            }
            
        }
    }
    
}
