//
//  GameScene_Player.swift
//  PlayAround
//
//  Created by Bret Williams on 1/20/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {

    func move(theXAmount:CGFloat, theYAmount:CGFloat, theAnimation:String) {
        
        let walkAction:SKAction = SKAction(named: theAnimation)!
        let moveAction:SKAction = SKAction.moveBy(x: theXAmount, y:theYAmount, duration: 1)
        
        let group:SKAction = SKAction.group([walkAction, moveAction])
        
        thePlayer.run(group)
        
     //   print (theAnimation)
    }

    
    
    // MARK: Attack
    func attack() {
        
     //   print ("attacking")
        
        let newAttack:AttackArea = AttackArea(imageNamed: "AttackCircle")
        newAttack.position = thePlayer.position
        newAttack.scaleSize = thePlayer.meleeScaleSize
        newAttack.animationName = thePlayer.meleeAnimationFXName
        newAttack.damage = thePlayer.meleeDamage
        
        newAttack.setUp()
        self.addChild(newAttack)
        newAttack.zPosition = thePlayer.zPosition - 1
        
        var animationName : String = ""
        
        switch playerFacing {
            case .front,.none :
                animationName = thePlayer.frontMelee
            case .back :
                animationName = thePlayer.backMelee
                newAttack.xScale = -1
                newAttack.yScale = -1
            case .left :
                animationName = thePlayer.leftMelee
                newAttack.xScale = -1
            case .right :
                animationName = thePlayer.rightMelee
        }
        
        let attackAnimation:SKAction = SKAction(named: animationName)!
        
        let finish:SKAction = SKAction.run {
            self.runIdleAnimation()
        }
        
        let seq:SKAction = SKAction.sequence( [attackAnimation, finish])
        
        thePlayer.run(seq, withKey: "Attack")
        
        restoreAndFadeInAttackButtons()
        
    }
    
    func rangedAttack(withDict:[String:Any]) {
        
    //    print(withDict)
        
        let newProjectile:Projectile = Projectile(imageNamed: prevPlayerProjectileImageName)
        newProjectile.position = thePlayer.position
        newProjectile.setUpWithDict(theDict: withDict)

        self.addChild(newProjectile)
        
        var moveAction:SKAction = SKAction()
        var theDistance:CGFloat = 0
        
        if (newProjectile.distance > 0) {
            theDistance = newProjectile.distance
        } else {
            
            if (playerFacing == .front || playerFacing == .back) {
                
                theDistance = (self.view?.bounds.size.height)!
                
            } else {
                
                theDistance = (self.view?.bounds.size.width)!
                
            }
        }
        
        var animationName:String = ""
        
        switch playerFacing {
        case .front,.none:
            moveAction = SKAction.moveBy(x: 0, y: -theDistance, duration: newProjectile.travelTime)
            animationName = thePlayer.frontRanged
            newProjectile.position = CGPoint(x: newProjectile.position.x, y: newProjectile.position.y - newProjectile.offset)
        case .back:
            moveAction = SKAction.moveBy(x: 0, y: theDistance, duration: newProjectile.travelTime)
            animationName = thePlayer.backRanged
            newProjectile.position = CGPoint(x: newProjectile.position.x, y: newProjectile.position.y + (newProjectile.offset * 2))
        case .right:
            moveAction = SKAction.moveBy(x: theDistance, y: 0, duration: newProjectile.travelTime)
            animationName = thePlayer.rightRanged
            newProjectile.position = CGPoint(x: newProjectile.position.x + newProjectile.offset, y: newProjectile.position.y)
        case .left:
            moveAction = SKAction.moveBy(x: -theDistance, y: 0, duration: newProjectile.travelTime)
            animationName = thePlayer.leftRanged
            newProjectile.position = CGPoint(x: newProjectile.position.x - newProjectile.offset, y: newProjectile.position.y)
        }
        
        moveAction.timingMode = .easeOut
        let finish:SKAction = SKAction.run {
            
            if(newProjectile.removeAfterThrow) {
                newProjectile.removeFromParent()
            }
        }
        
        let seq:SKAction = SKAction.sequence([moveAction, finish])
        newProjectile.run(seq)
        
        //make it spin!
        if (newProjectile.rotationTime > 0) {
            
            let randomAddOn:UInt32 = arc4random_uniform(10)
            let addOn:CGFloat = CGFloat(randomAddOn / 10)
            let rotateAction:SKAction = SKAction.rotate(byAngle: 6.28319 + addOn, duration: newProjectile.rotationTime)
            let repeatRotate:SKAction = SKAction.repeat(rotateAction, count: Int(newProjectile.travelTime / newProjectile.rotationTime))
            
            newProjectile.run(repeatRotate)
            
        }
        
        if (animationName != "") {
            
            let attackAnimation:SKAction = SKAction(named: animationName)!
            let finish:SKAction = SKAction.run {
                
                if (!self.walkWithPath) {
                    
                    if (self.touchingDown) {
                        
                        self.animateWalkSansPath()
                        
                    }
                } else {
                    
                    self.runIdleAnimation()
                }
                
                self.restoreAndFadeInAttackButtons()
            }
            
            let seq:SKAction = SKAction.sequence([attackAnimation, finish])
            thePlayer.run(seq, withKey: "Attack")
        }
        
        
        if (currentProjectileRequiresAmmo) {
            
            subtractAmmo(amount: 1)
            
        }
        
        //Not needed when using the button attack interface
        /*
        if (!walkWithPath) {
            
            touchingDown = false
            
            thePlayer.removeAction(forKey: thePlayer.backWalk)
            thePlayer.removeAction(forKey: thePlayer.frontWalk)
            thePlayer.removeAction(forKey: thePlayer.rightWalk)
            thePlayer.removeAction(forKey: thePlayer.leftWalk)
            
        }
        */
        
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
      //  if (thePlayer.action(forKey: "PlayerMoving") != nil) {
            
      //      thePlayer.removeAction(forKey: "PlayerMoving")
      //  }
        
        pathArray.removeAll()
        
        currentOffset = CGPoint(x: thePlayer.position.x - pos.x, y: thePlayer.position.y - pos.y)
        
        pathArray.append(getDifference(point: pos))
        
        walkTime = 0
        
      /*
        print ("(\(pos.x),\(pos.y))")
        
        if ( pos.y > 0) {
            
            if (pos.x > 0) {
                print ("quadrant 1")
            } else {
                print ("quadrant 2")
            }
            
        } else {
            // y < 0
            if (pos.x > 0) {
                print ("quadrant 4")
            } else {
                print ("quadrant 3")
            }
        }
        
        // swipedRight()
        */
    }
    
    func touchDownSansPath(atPoint pos : CGPoint) {
        
        if (pos.x < thePlayer.position.x) {
            
            // to the left of the player
            
            touchingDown = true
            thePlayer.removeAction(forKey: "Idle")
            offsetFromTouchDownToPlayer = CGPoint(x: thePlayer.position.x - pos.x, y: thePlayer.position.y - pos.y)
            
            if(touchDownSprite.parent == nil) {
                touchDownSprite = SKSpriteNode(imageNamed: "TouchDown")
                self.addChild(touchDownSprite)
                touchDownSprite.position = pos
            } else {
                touchDownSprite.position = pos
            }
            
            if(touchFollowSprite.parent == nil) {
                touchFollowSprite = SKSpriteNode(imageNamed: "TouchDown")
                self.addChild(touchFollowSprite)
                touchFollowSprite.position = pos
            } else {
                touchFollowSprite.position = pos
            }
            
        }
        
        
    }
    
    // MARK: Melle or Ranged pre-Attack
    
    
    func melee() {
        
        if(!disableAttack) {
            
            attack()
            
        }
        
    }
    
    func switchWeaponsIfNeeded(includingAddAmmo:Bool) {
        
        var foundAmmoEntry:Bool = false
        
        if(thePlayer.currentProjectile != "") {
            
            if (prevPlayerProjectileName != thePlayer.currentProjectile) {
            
                for (key, value) in projectilesDict {
                    
                    switch key {
                        
                    case thePlayer.currentProjectile:
                       
                        prevPlayerProjectileName = key
                        prevPlayerProjectileDict = value as! [String : Any]
                        defaults.set(thePlayer.currentProjectile, forKey: "CurrentProjectile")
                        
                        for (k,v) in prevPlayerProjectileDict {
                            
                            switch k {
                            case "Image":
                                if (v is String) {
                                    
                                    prevPlayerProjectileImageName = v as! String
                                    
                                }
                            case "Icon":
                                if (v is String) {
                                    
                                    projectileIcon.texture = SKTexture(imageNamed:v as! String)
                                    
                                }
                            case "Ammo":
                                if (v is Int) {
                                    
                                    foundAmmoEntry = true
                                    if (includingAddAmmo) {
                                        
                                        addToAmmo(amount: v as! Int)
                                        
                                    }
                                }
                            default:
                                continue
                            }
                        }
                        
                    default:
                        continue
                    }

                    currentProjectileRequiresAmmo = foundAmmoEntry
                    setAmmoLabel()
                    
                    break
                    
                }
                
            }
        }

    }
    
    func ranged() {
        
        if(!disableAttack) {
            
            if (currentProjectileRequiresAmmo && currentProjectileAmmo > 0) {
                
                rangedAttack(withDict: prevPlayerProjectileDict)
                
            } else if (!currentProjectileRequiresAmmo) {
                
                rangedAttack(withDict: prevPlayerProjectileDict)
                
            }
            
        }
    }
    
    func checkIfMeleeButtonPressed(pos:CGPoint) -> Bool {
        
        var pressed:Bool = false
        
        let meleeLocation:CGPoint = convert(meleeAttackButton.position, from:self.camera!)
        let meleeFrame:CGRect = CGRect(x:meleeLocation.x - (meleeAttackButton.frame.size.width / 2),
                                       y:meleeLocation.y - (meleeAttackButton.frame.size.height / 2),
                                       width: meleeAttackButton.frame.size.width,
                                       height: meleeAttackButton.frame.size.height)
        
        if(meleeFrame.contains(pos)) {
            
            pressed = true
            highlightAndFadeAttackButtons()
            
        }
        
        return pressed
    }
    
    func checkIfRangedButtonPressed(pos:CGPoint) -> Bool {
        
        var pressed:Bool = false
        
        let rangedLocation:CGPoint = convert(rangedAttackButton.position, from:self.camera!)
        let rangedFrame:CGRect = CGRect(x:rangedLocation.x - (rangedAttackButton.frame.size.width / 2),
                                       y:rangedLocation.y - (rangedAttackButton.frame.size.height / 2),
                                       width: rangedAttackButton.frame.size.width,
                                       height: rangedAttackButton.frame.size.height)
        
        if(rangedFrame.contains(pos)) {
            
            pressed = true
            highlightAndFadeAttackButtons()
            
        }
        
        return pressed
    }
    
    func restoreAndFadeInAttackButtons() {
        
        rangedAttackButton.removeAllActions()
        meleeAttackButton.removeAllActions()
        
     //   rangedAttackButton.alpha = 1
     //   meleeAttackButton.alpha = 1
        
        let fadeIn:SKAction = SKAction.fadeIn(withDuration: 5)
        rangedAttackButton.run(fadeIn)
        meleeAttackButton.run(fadeIn)
        
    }
    
    func highlightAndFadeAttackButtons() {
        
        rangedAttackButton.removeAllActions()
        meleeAttackButton.removeAllActions()
        
        rangedAttackButton.alpha = 1
        meleeAttackButton.alpha = 1
        
        let fadeOut:SKAction = SKAction.fadeOut(withDuration: 1)
        rangedAttackButton.run(fadeOut)
        meleeAttackButton.run(fadeOut)
        
    }
    

    func getDifference(point:CGPoint) -> CGPoint {
        
        let newPoint:CGPoint = CGPoint(x: point.x + currentOffset.x, y: point.y + currentOffset.y)
        
        return newPoint
    }
    
    func touchMovedSansPath(toPoint pos : CGPoint) {
        
        if(touchingDown) {
            
            orientCharacter(pos:pos)
            touchFollowSprite.position = pos
        }
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
        if (thePlayer.action(forKey: "PlayerMoving") != nil && pathArray.count > 4) {
        
           thePlayer.removeAction(forKey: "PlayerMoving")
        }
        
        walkTime += thePlayer.walkSpeedOnPath
        
        pathArray.append(getDifference(point: pos))
    }
    
    func touchUp(atPoint pos : CGPoint) {
        //  swipedRight()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (thePlayer.isDead) {
            return
        }
        
        for t in touches {
            
            let pos:CGPoint = t.location(in: self)
            
            if(checkIfMeleeButtonPressed(pos: pos)) {
                
                melee()
                
            } else if (checkIfRangedButtonPressed(pos: pos))  {
            
                ranged()
        
            } else if (walkWithPath) {
                
                self.touchDown(atPoint: pos)
                
            } else {
                
                self.touchDownSansPath(atPoint: pos)
                
            }
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (thePlayer.isDead) {
            return
        }
        
        for t in touches {
            
            let pos:CGPoint = t.location(in: self)
            
            if(checkIfMeleeButtonPressed(pos: pos)) {
                
                //ignore
                
            } else if (checkIfRangedButtonPressed(pos: pos))  {
                
                //ignore
                
            } else if (walkWithPath) {
                
                self.touchMoved(toPoint: pos)
                
            } else {
                
                self.touchMovedSansPath(toPoint: pos)
            }
            
            break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (thePlayer.isDead) {
            return
        }
        
        for t in touches {
            
            let pos:CGPoint = t.location(in: self)
            
            if(checkIfMeleeButtonPressed(pos: pos)) {
                
                //ignore
                
            } else if (checkIfRangedButtonPressed(pos: pos))  {
                
                //ignore
                
            } else if (walkWithPath) {
                
                self.touchEnded(toPoint: pos)
                
            } else {
                
                self.touchEndedSansPath(toPoint: pos)
            }
            
            break
        }
    }
    
    func touchEnded(toPoint pos:CGPoint) {
        
        createLineWith(array:pathArray)
        pathArray.removeAll()
        
        currentOffset = CGPoint.zero
        
    }
    
    func touchEndedSansPath(toPoint pos:CGPoint) {
        
        if(touchingDown) {
            
            thePlayer.removeAction(forKey: "PlayerMoving")
            touchingDown = false
            touchFollowSprite.removeFromParent()
            touchDownSprite.removeFromParent()
            
            runIdleAnimation()
            
        }
        
    }
    
    func createLineWith(array:[CGPoint])  {
        
        let path = CGMutablePath()
        path.move(to:pathArray[0])
        
        for point in pathArray {
            
            path.addLine(to:point)
            
        }
        
        let line = SKShapeNode()
        line.path = path
        line.lineWidth = 10
        line.strokeColor = UIColor.white
        line.alpha = pathAlpha
        
        self.addChild(line)
        
        let fade:SKAction = SKAction.fadeOut(withDuration: 0.3)
        let runAfter:SKAction = SKAction.run {
            
            line.removeFromParent()
            
        }
        
        line.run(SKAction.sequence([fade, runAfter]))
        
        makePlayerFollowPath(path: path)
        
    }
    
    func playerUpdateSansPath() {
        
        touchDownSprite.position = CGPoint(x:thePlayer.position.x - offsetFromTouchDownToPlayer.x, y:thePlayer.position.y - offsetFromTouchDownToPlayer.y)
        
        if (touchingDown) {
            
            let walkSpeed = thePlayer.walkSpeed
            
            switch playerFacing {
            case .front,.none:
                thePlayer.position = CGPoint(x:thePlayer.position.x + diagonalAmount, y:thePlayer.position.y - walkSpeed)
            case .back:
                thePlayer.position = CGPoint(x:thePlayer.position.x + diagonalAmount, y:thePlayer.position.y + walkSpeed)
            case .left:
                thePlayer.position = CGPoint(x:thePlayer.position.x - walkSpeed, y:thePlayer.position.y + diagonalAmount)
            case .right:
                thePlayer.position = CGPoint(x:thePlayer.position.x + walkSpeed, y:thePlayer.position.y + diagonalAmount)
            }
         
            animateWalkSansPath()
        }
        
    }
    
    func playerUpdate() {
        
        //runs at the same frame rate as the game (called by the update statement)
        
        if (thePlayer.action(forKey: "PlayerMoving") != nil && thePlayer.action(forKey: "Attack") == nil) {
        
            if (playerLastLocation != CGPoint.zero) {
                
                if (thePlayer.action(forKey: "PlayerMoving") != nil) {
                
                    if (abs(thePlayer.position.x - playerLastLocation.x) > abs(thePlayer.position.y - playerLastLocation.y)) {
                        //greater movement x
                        
                        if (thePlayer.position.x > playerLastLocation.x) {
                            //right
                            playerFacing = .right
                            
                            if (thePlayer.action(forKey: thePlayer.rightWalk) == nil) {
                                
                                animateWalk()
                            }
                            
                        } else {
                            //left
                            playerFacing = .left
                            
                            if (thePlayer.action(forKey: thePlayer.leftWalk) == nil) {
                                
                                animateWalk()
                            }
                        }
                        
                    } else {
                        //greater movement y
                        
                        if (thePlayer.position.y > playerLastLocation.y) {
                            //up / back
                            
                            playerFacing = .back
                            
                            if (thePlayer.action(forKey: thePlayer.backWalk) == nil) {
                                
                                animateWalk()
                            }
                            
                        } else {
                            //down / forward
                            
                            playerFacing = .front
                            
                            if (thePlayer.action(forKey: thePlayer.frontWalk) == nil) {
                                
                                animateWalk()
                            }
                            
                        }
                        
                    }
                
                }
                
            }
            
        }
        
        playerLastLocation = thePlayer.position
    }
    
    func orientCharacter(pos:CGPoint) {
                    
        if (abs(touchDownSprite.position.x - pos.x) > abs(touchDownSprite.position.y - pos.y)) {
            //greater movement x
            
            if (touchDownSprite.position.x < pos.x) {
                
                //right
                playerFacing = .right
              
            } else {
                
                //left
                playerFacing = .left
                
            }
            
            if (walkDiagonal) {
                
                diagonalAmount = ((touchDownSprite.position.y - pos.y) / 100) * (thePlayer.walkSpeed / 2)
                if(diagonalAmount > 0 && diagonalAmount > (thePlayer.walkSpeed / 2)) {
                    diagonalAmount = (thePlayer.walkSpeed / 2)
                } else if (diagonalAmount < 0 && diagonalAmount < (thePlayer.walkSpeed / 2)) {
                    diagonalAmount = -(thePlayer.walkSpeed / 2)
                }
                
            }
            
        } else {
            //greater movement y
            
            if (touchDownSprite.position.y < pos.y) {
                //up / back
                
                playerFacing = .back
                
                
            } else {
                //down / forward
                
                playerFacing = .front
                
            }
            
            if (walkDiagonal) {
                
                diagonalAmount = -((touchDownSprite.position.x - pos.x) / 100) * (thePlayer.walkSpeed / 2)
                if(diagonalAmount > 0 && diagonalAmount > (thePlayer.walkSpeed / 2)) {
                    diagonalAmount = (thePlayer.walkSpeed / 2)
                } else if (diagonalAmount < 0 && diagonalAmount < (thePlayer.walkSpeed / 2)) {
                    diagonalAmount = -(thePlayer.walkSpeed / 2)
                }
                
            }
            
        }
        
        if (thingBeingUnlocked != "") {
            
            if (playerFacingWhenUnlocking != playerFacing) {
                //should refactor this to call removeTimer() in the _Physics file
                
                if (self.childNode(withName: thingBeingUnlocked + "Timer") == nil) {
                    
                    self.childNode(withName: thingBeingUnlocked + "Timer")?.removeAllActions()
                    self.childNode(withName: thingBeingUnlocked + "Timer")?.removeFromParent()
                    
                }
                
                thingBeingUnlocked = ""
                fadeOutInfoText(waitTime: 0.5)
            }
            
        }

    }
    
    func animateWalk() {
        
        if (thePlayer.action(forKey: "Hurt") == nil) {
        
            var theAnimation:String = ""
            
            switch playerFacing {
            case .right:
                theAnimation = thePlayer.rightWalk
            case .left:
                theAnimation = thePlayer.leftWalk
            case .front,.none:
                theAnimation = thePlayer.frontWalk
            case .back:
                theAnimation = thePlayer.backWalk
            }
            
            let walkAnimation:SKAction = SKAction.init(named: theAnimation)!
            thePlayer.run(walkAnimation, withKey: theAnimation)
            
        }
    }
    
    func animateWalkSansPath() {
        
        if (thePlayer.action(forKey: "Hurt") == nil) {
            
            var theAnimation:String = ""
            
            switch playerFacing {
            case .right:
                theAnimation = thePlayer.rightWalk
            case .left:
                theAnimation = thePlayer.leftWalk
            case .front,.none:
                theAnimation = thePlayer.frontWalk
            case .back:
                theAnimation = thePlayer.backWalk
            }
            
            if (theAnimation != "") {
            
                thePlayer.removeAction(forKey: thePlayer.rightWalk)
                thePlayer.removeAction(forKey: thePlayer.leftWalk)
                thePlayer.removeAction(forKey: thePlayer.frontWalk)
                thePlayer.removeAction(forKey: thePlayer.backWalk)
                
                let walkAnimation:SKAction = SKAction.init(named: theAnimation)!
                let repeatAction:SKAction = SKAction.repeatForever(walkAnimation)
                thePlayer.run(repeatAction, withKey: theAnimation)
                
            }
        }
        
    }
    
    func makePlayerFollowPath(path:CGMutablePath) {
        
        let followAction:SKAction = SKAction.follow(path, asOffset: false, orientToPath: false, duration: walkTime)
        
        let finish:SKAction = SKAction.run {
            
            self.runIdleAnimation()
            
        }
        
        let seq:SKAction = SKAction.sequence([followAction, finish])
        
        thePlayer.run(seq, withKey: "PlayerMoving")
        
    }
    
    func runIdleAnimation() {
        
        var animationName:String = ""
        
        switch playerFacing {
            
            case .front,.none:
                animationName = thePlayer.frontIdle
            case .back:
                animationName = thePlayer.backIdle
            case .left:
                animationName = thePlayer.leftIdle
            case .right:
                animationName = thePlayer.rightIdle
        }
        
        if (animationName != "") {
            let idleAnimation:SKAction = SKAction(named: animationName, duration:1)!
            thePlayer.run(idleAnimation, withKey: "Idle")
        }
    }
    
    func hurtAnimation() {
        
        var theAnimation:String = ""
        
        switch playerFacing {
        case .right:
            theAnimation = thePlayer.rightHurt
        case .left:
            theAnimation = thePlayer.leftHurt
        case .back:
            theAnimation = thePlayer.backHurt
        case .front:
            theAnimation = thePlayer.frontHurt
        case .none:
            break
        }
        
        if (theAnimation != "") {
            
            if (thePlayer.action(forKey: theAnimation) != nil) {
                
                thePlayer.removeAction(forKey: thePlayer.rightWalk)
                thePlayer.removeAction(forKey: thePlayer.leftWalk)
                thePlayer.removeAction(forKey: thePlayer.backWalk)
                thePlayer.removeAction(forKey: thePlayer.frontWalk)
                
                if let hurtAnimation:SKAction = SKAction(named: theAnimation) {
                    thePlayer.run(hurtAnimation, withKey: "Hurt")
                }
            }
            
        }
        
    }
    
    
    func killPlayer() {
        
        thePlayer.removeAllActions()
        print("kill player")
        
        var theAnimation:String = ""
        thePlayer.isDead = true
        
        
        switch playerFacing {
        case .right:
            theAnimation = thePlayer.rightDying
        case .left:
            theAnimation = thePlayer.leftDying
        case .back:
            theAnimation = thePlayer.backDying
        case .front:
            theAnimation = thePlayer.frontDying
        case .none:
            break
        }
        
        print (theAnimation)
        if (theAnimation != "") {
        
            if let dyingAnimation:SKAction = SKAction(named: theAnimation) {
               
                let finish:SKAction = SKAction.run {
                    self.resetLevel()
                    print("running the sequence")
                }
                
                let seq:SKAction = SKAction.sequence([dyingAnimation, finish])
                thePlayer.run(seq)
                
            } else {
                
                self.resetLevel()
                
            }
            
        }  else {
        
            self.resetLevel()
        
        }
        
    }
    
    func damagePlayer(with amount:Int) {
        
        if (thePlayer.canBeDamaged) {
            
            //print ("can be damaged")
            
            hurtAnimation()
            thePlayer.damaged()
            
            if (currentArmor > 0) {
                subtractArmor(amount: amount)
            } else {
                subtractHealth(amount: amount)
            }
        }
        
    }
    
    func resetLevel() {
        
        var initialLevel:String = ""
        var initialEntryNode:String = ""
        
        if (defaults.object(forKey: "ContinuePoint") != nil) {
            
            initialLevel = defaults.string(forKey: "ContinuePoint")!
            
        } else {
            
            initialLevel = currentLevel
        }
        
        if (defaults.object(forKey: "ContinueWhere") != nil) {
            
            initialEntryNode = defaults.string(forKey: "ContinueWhere")!
            
        }
        print ("Reset level")
        loadLevel(theLevel: initialLevel, toWhere: initialEntryNode)
        
    }
   
}
