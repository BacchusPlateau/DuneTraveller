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
            
            let (col, row) = tileCoordinates(in: wallTileMap!, at: thePlayer.position)
            print("Player is at \(col),\(row)")
            
            fogOfWar(map: wallTileMap!, fromNode: thePlayer.position)
            
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
    
   
    
    func createLineWith(array:[CGPoint])  {
        
        let path = CGMutablePath()
        path.move(to:pathArray[0])
        
        for point in pathArray {
            
            path.addLine(to:point)
            
        }
        
        let line = SKShapeNode()
        line.path = path
        line.physicsBody?.collisionBitMask = BodyType.door.rawValue | BodyType.wall.rawValue
        line.physicsBody?.categoryBitMask = BodyType.path.rawValue
        line.physicsBody?.isDynamic = false
        line.lineWidth = 10
        //  line.strokeColor = UIColor.white
        line.alpha = pathAlpha
        
        self.addChild(line)
        
        let fade:SKAction = SKAction.fadeOut(withDuration: 0.3)
        let runAfter:SKAction = SKAction.run {
            
            line.removeFromParent()
            
        }
        
        line.run(SKAction.sequence([fade, runAfter]))
        
        makePlayerFollowPath(path: path)
        
        
        
    }
    
    
    
    func getDifference(point:CGPoint) -> CGPoint {
        
        let newPoint:CGPoint = CGPoint(x: point.x + currentOffset.x, y: point.y + currentOffset.y)
        
        return newPoint
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
    
    override func keyDown(with event: NSEvent) {
        
        switch event.keyCode {
        case 0x00: // A, attack
            melee()
        case 0x03: // F, fire projectile
            ranged()
        case 0x22: // I, inventory toggle
            toggleInventory()
        case 0x01: // S, search
            searchAround()
        case 0x31: // Space, pause
            break
        default:
            break
        }
    }
    
    
    
    func makePlayerFollowPath(path:CGMutablePath) {
        //      print ("walktime = " + String(walkTime))
        
        if (walkTime > 5) {
            walkTime = 5
        }
        
        let followAction:SKAction = SKAction.follow(path, asOffset: false, orientToPath: false, duration: walkTime)
        
        let finish:SKAction = SKAction.run {
            
            self.runIdleAnimation()
            
        }
        
        let seq:SKAction = SKAction.sequence([followAction, finish])
        
        thePlayer.run(seq, withKey: "PlayerMoving")
        
    }
    
    func melee() {
        
        if(!disableAttack) {
            
            attack()
            
        }
        
    }
    
    // MARK:  MOUSE
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    func move(theXAmount:CGFloat, theYAmount:CGFloat, theAnimation:String) {
        
        let walkAction:SKAction = SKAction(named: theAnimation)!
        let moveAction:SKAction = SKAction.moveBy(x: theXAmount, y:theYAmount, duration: 1)
        
        let group:SKAction = SKAction.group([walkAction, moveAction])
        
        thePlayer.run(group)
        
        //   print (theAnimation)
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
    
    func playerUpdateSansPath() {
        
        print("playerUpdateSansPath")
        
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
    
  
    func ranged() {
        
        if(!disableAttack) {
            
            if (currentProjectileRequiresAmmo && currentProjectileAmmo > 0) {
                
                rangedAttack(withDict: prevPlayerProjectileDict)
                
            } else if (!currentProjectileRequiresAmmo) {
                
                rangedAttack(withDict: prevPlayerProjectileDict)
                
            }
            
        }
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
                self.runIdleAnimation()
                self.restoreAndFadeInAttackButtons()
            }
            
            let seq:SKAction = SKAction.sequence([attackAnimation, finish])
            thePlayer.run(seq, withKey: "Attack")
        }
        
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
    
    //called when S is pressed
    func searchAround() {
        
        //search 1 square all around the user's current place on the map
        //we will throw a dialog of either nothing found, a dialog box with info, or adding an item to inventory
        let (col, row) = tileCoordinates(in: wallTileMap!, at: thePlayer.position)
        
        searchAreas.forEach { area in
            if searchArea(playerX: col, playerY: row, area: area) == true {
                
                var showTheSearchResult: Bool = false
                
                //check for encounter volatility and act accordingly
                if let encounter = overlay.first(where: { $0.encounterId == area.encounterId }) {
                    
                    if encounter.volatile && !encounter.completed {
                        showTheSearchResult = true
                        //assumption: only volatile searches will have inventory search results
                        let searchData = SearchAreaData()
                        let booty = searchData.getIventoryFoundInSearch(forSearchAreaId: area.id)
                        if booty.getInventoryCount() > 0 {
                            playerInventory.MergeInventory(withInventory: booty)
                        }
                    }
                    
                    if !encounter.volatile {
                        showTheSearchResult = true
                    }
                    
                    if showTheSearchResult {
                        
                        splitTextIntoFields(theText: area.message)
                        fadeOutInfoText(waitTime: 5)
                        
                        encounter.completed = true
                        
                    } else {
                        
                        splitTextIntoFields(theText: "You look around but find nothing.")
                        fadeOutInfoText(waitTime: 5)
                        
                    }
                }
                
            }
        }
        
        print("Search at \(col), \(row)!")
    }
    
    func searchArea(playerX: Int, playerY: Int, area: SearchArea) -> Bool {
        
        var didFind: Bool = false
        
        //distance formula.  thanks Pythagoras!
        let step1 = pow(Decimal(playerX - Int(area.tilePosition.x)), 2) +
                    pow(Decimal(playerY - Int(area.tilePosition.y)), 2)
        
        let step2 = NSDecimalNumber(decimal: step1).doubleValue
        
        let step3 = sqrt(step2)
            
        if step3 <= Double(area.searchRadius) {
            didFind = true
        }
            
        return didFind
        
    }
    
    
    
    
    func toggleInventory() {
        
        inventoryVisible = !inventoryVisible
        
        if let statsBacking = self.camera!.childNode(withName: "StatsBacking") as? SKSpriteNode {
            statsBacking.alpha = inventoryVisible ? 1 : 0
        }
        
        if let classLabel = self.camera!.childNode(withName: "ClassLabel") as? SKLabelNode {
            classLabel.alpha = inventoryVisible ? 1 : 0
        }
        
        if let xpLevelLabel = self.camera!.childNode(withName: "XPLevelLabel") as? SKLabelNode {
            xpLevelLabel.alpha = inventoryVisible ? 1 : 0
        }
        
        if let XPLabel = self.camera!.childNode(withName: "XPLabel") as? SKLabelNode {
            XPLabel.alpha = inventoryVisible ? 1 : 0
        }
        
        if let currencyLabel = self.camera!.childNode(withName: "CurrencyLabel") as? SKLabelNode {
            currencyLabel.alpha = inventoryVisible ? 1 : 0
        }
        
        if let healthLabel = self.camera!.childNode(withName: "HealthLabel") as? SKLabelNode {
            healthLabel.alpha = inventoryVisible ? 1 : 0
        }
        
        if let armorLabel = self.camera!.childNode(withName: "ArmorLabel") as? SKLabelNode {
            armorLabel.alpha = inventoryVisible ? 1 : 0
        }
        
        
        if let projectileBacking = self.camera!.childNode(withName: "ProjectileBacking") as? SKSpriteNode {
            projectileBacking.alpha = inventoryVisible ? 1 : 0
        }
        
        if let projectileIcon = self.camera!.childNode(withName: "ProjectileIcon") as? SKSpriteNode {
            projectileIcon.alpha = inventoryVisible ? 1 : 0
        }
        
        if let ammoLabel = self.camera!.childNode(withName: "AmmoLabel") as? SKLabelNode {
            ammoLabel.alpha = inventoryVisible ? 1 : 0
        }
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
        pathArray.removeAll()
        currentOffset = CGPoint(x: thePlayer.position.x - pos.x, y: thePlayer.position.y - pos.y)
        pathArray.append(getDifference(point: pos))
        walkTime = 0
    }
    
    func touchDownSansPath(atPoint pos : CGPoint) {
        
        print("touchDownSansPath")
        
        destinationPoint = pos
        
        pathArray.removeAll()
        
        currentOffset = CGPoint(x: thePlayer.position.x - pos.x, y: thePlayer.position.y - pos.y)
        
        pathArray.append(getDifference(point: pos))
        
        walkTime = 0
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
        
        if (thePlayer.action(forKey: "PlayerMoving") != nil && pathArray.count > 4) {
            
            thePlayer.removeAction(forKey: "PlayerMoving")
        }
        
        walkTime += thePlayer.walkSpeedOnPath
        
        pathArray.append(getDifference(point: pos))
        
    }
    
    
    
    
    
    func touchEnded(toPoint pos:CGPoint) {
        
        createLineWith(array:pathArray)
        pathArray.removeAll()
        
        currentOffset = CGPoint.zero
        
    }
    
   
    
    func touchUp(atPoint pos : CGPoint) {
        touchEnded(toPoint: pos)
    }
    
    
    
    
    
    
}

// MARK: Key Map

/*
 *  Summary:
 *    Virtual keycodes
 *
 *  Discussion:
 *    These constants are the virtual keycodes defined originally in
 *    Inside Mac Volume V, pg. V-191. They identify physical keys on a
 *    keyboard. Those constants with "ANSI" in the name are labeled
 *    according to the key position on an ANSI-standard US keyboard.
 *    For example, kVK_ANSI_A indicates the virtual keycode for the key
 *    with the letter 'A' in the US keyboard layout. Other keyboard
 *    layouts may have the 'A' key label on a different physical key;
 *    in this case, pressing 'A' will generate a different virtual
 *    keycode.
 
enum {
    kVK_ANSI_A                    = 0x00,
    kVK_ANSI_S                    = 0x01,
    kVK_ANSI_D                    = 0x02,
    kVK_ANSI_F                    = 0x03,
    kVK_ANSI_H                    = 0x04,
    kVK_ANSI_G                    = 0x05,
    kVK_ANSI_Z                    = 0x06,
    kVK_ANSI_X                    = 0x07,
    kVK_ANSI_C                    = 0x08,
    kVK_ANSI_V                    = 0x09,
    kVK_ANSI_B                    = 0x0B,
    kVK_ANSI_Q                    = 0x0C,
    kVK_ANSI_W                    = 0x0D,
    kVK_ANSI_E                    = 0x0E,
    kVK_ANSI_R                    = 0x0F,
    kVK_ANSI_Y                    = 0x10,
    kVK_ANSI_T                    = 0x11,
    kVK_ANSI_1                    = 0x12,
    kVK_ANSI_2                    = 0x13,
    kVK_ANSI_3                    = 0x14,
    kVK_ANSI_4                    = 0x15,
    kVK_ANSI_6                    = 0x16,
    kVK_ANSI_5                    = 0x17,
    kVK_ANSI_Equal                = 0x18,
    kVK_ANSI_9                    = 0x19,
    kVK_ANSI_7                    = 0x1A,
    kVK_ANSI_Minus                = 0x1B,
    kVK_ANSI_8                    = 0x1C,
    kVK_ANSI_0                    = 0x1D,
    kVK_ANSI_RightBracket         = 0x1E,
    kVK_ANSI_O                    = 0x1F,
    kVK_ANSI_U                    = 0x20,
    kVK_ANSI_LeftBracket          = 0x21,
    kVK_ANSI_I                    = 0x22,
    kVK_ANSI_P                    = 0x23,
    kVK_ANSI_L                    = 0x25,
    kVK_ANSI_J                    = 0x26,
    kVK_ANSI_Quote                = 0x27,
    kVK_ANSI_K                    = 0x28,
    kVK_ANSI_Semicolon            = 0x29,
    kVK_ANSI_Backslash            = 0x2A,
    kVK_ANSI_Comma                = 0x2B,
    kVK_ANSI_Slash                = 0x2C,
    kVK_ANSI_N                    = 0x2D,
    kVK_ANSI_M                    = 0x2E,
    kVK_ANSI_Period               = 0x2F,
    kVK_ANSI_Grave                = 0x32,
    kVK_ANSI_KeypadDecimal        = 0x41,
    kVK_ANSI_KeypadMultiply       = 0x43,
    kVK_ANSI_KeypadPlus           = 0x45,
    kVK_ANSI_KeypadClear          = 0x47,
    kVK_ANSI_KeypadDivide         = 0x4B,
    kVK_ANSI_KeypadEnter          = 0x4C,
    kVK_ANSI_KeypadMinus          = 0x4E,
    kVK_ANSI_KeypadEquals         = 0x51,
    kVK_ANSI_Keypad0              = 0x52,
    kVK_ANSI_Keypad1              = 0x53,
    kVK_ANSI_Keypad2              = 0x54,
    kVK_ANSI_Keypad3              = 0x55,
    kVK_ANSI_Keypad4              = 0x56,
    kVK_ANSI_Keypad5              = 0x57,
    kVK_ANSI_Keypad6              = 0x58,
    kVK_ANSI_Keypad7              = 0x59,
    kVK_ANSI_Keypad8              = 0x5B,
    kVK_ANSI_Keypad9              = 0x5C
};

/* keycodes for keys that are independent of keyboard layout*/
enum {
    kVK_Return                    = 0x24,
    kVK_Tab                       = 0x30,
    kVK_Space                     = 0x31,
    kVK_Delete                    = 0x33,
    kVK_Escape                    = 0x35,
    kVK_Command                   = 0x37,
    kVK_Shift                     = 0x38,
    kVK_CapsLock                  = 0x39,
    kVK_Option                    = 0x3A,
    kVK_Control                   = 0x3B,
    kVK_RightShift                = 0x3C,
    kVK_RightOption               = 0x3D,
    kVK_RightControl              = 0x3E,
    kVK_Function                  = 0x3F,
    kVK_F17                       = 0x40,
    kVK_VolumeUp                  = 0x48,
    kVK_VolumeDown                = 0x49,
    kVK_Mute                      = 0x4A,
    kVK_F18                       = 0x4F,
    kVK_F19                       = 0x50,
    kVK_F20                       = 0x5A,
    kVK_F5                        = 0x60,
    kVK_F6                        = 0x61,
    kVK_F7                        = 0x62,
    kVK_F3                        = 0x63,
    kVK_F8                        = 0x64,
    kVK_F9                        = 0x65,
    kVK_F11                       = 0x67,
    kVK_F13                       = 0x69,
    kVK_F16                       = 0x6A,
    kVK_F14                       = 0x6B,
    kVK_F10                       = 0x6D,
    kVK_F12                       = 0x6F,
    kVK_F15                       = 0x71,
    kVK_Help                      = 0x72,
    kVK_Home                      = 0x73,
    kVK_PageUp                    = 0x74,
    kVK_ForwardDelete             = 0x75,
    kVK_F4                        = 0x76,
    kVK_End                       = 0x77,
    kVK_F2                        = 0x78,
    kVK_PageDown                  = 0x79,
    kVK_F1                        = 0x7A,
    kVK_LeftArrow                 = 0x7B,
    kVK_RightArrow                = 0x7C,
    kVK_DownArrow                 = 0x7D,
    kVK_UpArrow                   = 0x7E
};

*/
