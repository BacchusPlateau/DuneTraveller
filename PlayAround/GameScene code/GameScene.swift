//
//  GameScene.swift
//  PlayAround
//
//  Created by Bret Williams on 12/27/17.
//  Copyright © 2017 Bret Williams. All rights reserved.
//

import SpriteKit
import GameplayKit

enum BodyType:UInt32 {
    case player = 1
    case item = 2
    case attackArea = 4
    case npc = 8
    case projectile = 16
    case enemy = 32
    case enemyAttackArea = 64
    case enemyProjectile = 128
}

enum Facing:Int {
    
    case front, back, left, right, none
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var thePlayer:Player = Player()
    var moveSpeed:TimeInterval = 1
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    let rotateRec = UIRotationGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    let tapRecDouble = UITapGestureRecognizer()
    
    public var currentLevel:String = ""
    
    var infoLabel1:SKLabelNode = SKLabelNode()
    var infoLabel2:SKLabelNode = SKLabelNode()
    var speechIcon:SKSpriteNode = SKSpriteNode()
    var isCollidable:Bool = false
    var transitionInProgress:Bool = false
    
    let defaults:UserDefaults = UserDefaults.standard
    
    var cameraFollowsPlayer:Bool = true
    var cameraXOffset:CGFloat = 0
    var cameraYOffset:CGFloat = 0
    var disableAttack:Bool = false
    
    var entryNode:String = ""
    
    var rewardDict = [String:Any]()
    var clearArray = [String]()
    
    var playerUsingPortal:Bool = false
    
    var pathArray = [CGPoint]()
    var currentOffset:CGPoint = CGPoint.zero
    
    var playerFacing:Facing = .front
    var playerFacingWhenUnlocking:Facing = .none
    var thingBeingUnlocked:String = ""
    var playerLastLocation:CGPoint = CGPoint.zero
    
    var walkTime:TimeInterval = 0
    
    var attackAnywhere:Bool = false
    var pathAlpha:CGFloat = 0.3
    var walkWithPath:Bool = false
    var touchingDown:Bool = false
    var touchDownSprite:SKSpriteNode = SKSpriteNode()
    var touchFollowSprite:SKSpriteNode = SKSpriteNode()
    var offsetFromTouchDownToPlayer:CGPoint = CGPoint.zero
    
    var hasCustomPadScene:Bool = false
    
    var projectilesDict = [String : Any]()
    var prevPlayerProjectileDict = [String : Any]()
    var prevPlayerProjectileName:String = ""
    var prevPlayerProjectileImageName:String = ""
    
    var meleeAttackButton:SKSpriteNode = SKSpriteNode()
    var rangedAttackButton:SKSpriteNode = SKSpriteNode()
    
    var diagonalAmount:CGFloat = 0
    var walkDiagonal:Bool = true
    
    var hasMeleeButton:Bool = false
    var hasRangedButton:Bool = false
    
    var healthLabel:SKLabelNode = SKLabelNode()
    var armorLabel:SKLabelNode = SKLabelNode()
    var xpLabel:SKLabelNode = SKLabelNode()
    var xpLevelLabel:SKLabelNode = SKLabelNode()
    var currencyLabel:SKLabelNode = SKLabelNode()
    var classLabel:SKLabelNode = SKLabelNode()
    
    var currentHealth:Int = 0
    var currentArmor:Int = 0
    
    var currentXP:Int = 0
    var maxXP:Int = 0
    var currency:Int = 0
    var xpLevel:Int = 0
    var xpArray = [[String:Any]]()
    
    var playerStartingClass:String = "Peasant"
    
    var ammoLabel:SKLabelNode = SKLabelNode()
    var projectileIcon:SKSpriteNode = SKSpriteNode()
    var projectileBacking:SKSpriteNode = SKSpriteNode()
    
    var currentProjectileRequiresAmmo:Bool = false
    var currentProjectileAmmo:Int = 0
    
    var availableInventorySlots = [String]()
    
    override func didMove(to view: SKView) {
        
        
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx:0, dy:0)
        
        self.enumerateChildNodes(withName: "//*") {
            node, stop in
        
            if let theCamera:SKCameraNode = node as? SKCameraNode {
      
                self.camera = theCamera
                
                if(theCamera.childNode(withName: "InfoLabel1") is SKLabelNode) {
                    self.infoLabel1 = theCamera.childNode(withName: "InfoLabel1") as! SKLabelNode
                    self.infoLabel1.text = ""
                }
                if(theCamera.childNode(withName: "InfoLabel2") is SKLabelNode) {
                    self.infoLabel2 = theCamera.childNode(withName: "InfoLabel2") as! SKLabelNode
                    self.infoLabel2.text = ""
                }
                if(theCamera.childNode(withName: "HealthLabel") is SKLabelNode) {
                    self.healthLabel = theCamera.childNode(withName: "HealthLabel") as! SKLabelNode
                    self.healthLabel.text = ""
                }
                if(theCamera.childNode(withName: "ArmorLabel") is SKLabelNode) {
                    self.armorLabel = theCamera.childNode(withName: "ArmorLabel") as! SKLabelNode
                    self.armorLabel.text = ""
                }
                if(theCamera.childNode(withName: "XPLabel") is SKLabelNode) {
                    self.xpLabel = theCamera.childNode(withName: "XPLabel") as! SKLabelNode
                    self.xpLabel.text = ""
                }
                if(theCamera.childNode(withName: "CurrencyLabel") is SKLabelNode) {
                    self.currencyLabel = theCamera.childNode(withName: "CurrencyLabel") as! SKLabelNode
                    self.currencyLabel.text = ""
                }
                if(theCamera.childNode(withName: "XPLevelLabel") is SKLabelNode) {
                    self.xpLevelLabel = theCamera.childNode(withName: "XPLevelLabel") as! SKLabelNode
                    self.xpLevelLabel.text = ""
                }
                if(theCamera.childNode(withName: "ClassLabel") is SKLabelNode) {
                    self.classLabel = theCamera.childNode(withName: "ClassLabel") as! SKLabelNode
                }
                if(theCamera.childNode(withName: "VillagerIcon") is SKSpriteNode) {
                    self.speechIcon = theCamera.childNode(withName: "VillagerIcon") as! SKSpriteNode
                    self.speechIcon.isHidden = true
                }
                if(theCamera.childNode(withName: "AmmoLabel") is SKLabelNode) {
                    self.ammoLabel = theCamera.childNode(withName: "AmmoLabel") as! SKLabelNode
                    self.ammoLabel.text = ""
                }
                if(theCamera.childNode(withName: "ProjectileIcon") is SKSpriteNode) {
                    self.projectileIcon = theCamera.childNode(withName: "ProjectileIcon") as! SKSpriteNode
                }
                if(theCamera.childNode(withName: "ProjectileBacking") is SKSpriteNode) {
                    self.projectileBacking = theCamera.childNode(withName: "ProjectileBacking") as! SKSpriteNode
                }
                if(theCamera.childNode(withName: "RangedButton") is SKSpriteNode) {
                    self.rangedAttackButton = theCamera.childNode(withName: "RangedButton") as! SKSpriteNode
                    self.hasRangedButton = true
                }
                if(theCamera.childNode(withName: "MeleeButton") is SKSpriteNode) {
                    self.meleeAttackButton = theCamera.childNode(withName: "MeleeButton") as! SKSpriteNode
                    self.hasMeleeButton = true
                }
                
                for i in 1...30 {
                    
                    if (theCamera.childNode(withName: "Slot" + String(i)) is SKSpriteNode) {
                        
                        self.availableInventorySlots.append("Slot" + String(i))
                        
                    }
                }
                
                print ("Available inventory slots:")
                print(self.availableInventorySlots)
                
                if(UIDevice.current.userInterfaceIdiom == .pad && !self.hasCustomPadScene) {
                    
                    print("no custom iPad SKS file, do our own adjustments")
                    theCamera.xScale = 1.5
                    theCamera.yScale = 1.5
                 
                    for node in theCamera.children {
                        
                        if (node.position.y > 0) {
                            node.position.y -= 100
                        } else {
                            node.position.y += 100
                        }
                    }
                }
                
                
                stop.pointee = true  //halt transversal of node tree
            }
        }
        
        if (!hasMeleeButton) {
        
            tapRec.addTarget(self, action: #selector(GameScene.tappedView(_:)))
            tapRec.numberOfTapsRequired = 1
            tapRec.numberOfTouchesRequired = 1
            self.view!.addGestureRecognizer(tapRec)
            
        }
        
        if (!hasRangedButton) {
            
            tapRecDouble.addTarget(self, action: #selector(GameScene.tappedViewDouble(_:)))
            tapRecDouble.numberOfTapsRequired = 2
            tapRecDouble.numberOfTouchesRequired = 1
            self.view!.addGestureRecognizer(tapRecDouble)
            
        }
        
        /*
        swipeRightRec.addTarget(self, action: #selector(GameScene.swipedRight))
        swipeRightRec.direction = .right
        self.view!.addGestureRecognizer(swipeRightRec)
        
        swipeLeftRec.addTarget(self, action: #selector(GameScene.swipedLeft))
        swipeLeftRec.direction = .left
        self.view!.addGestureRecognizer(swipeLeftRec)
        
        swipeDownRec.addTarget(self, action: #selector(GameScene.swipedDown))
        swipeDownRec.direction = .down
        self.view!.addGestureRecognizer(swipeDownRec)
        
        swipeUpRec.addTarget(self, action: #selector(GameScene.swipedUp))
        swipeUpRec.direction = .up
        self.view!.addGestureRecognizer(swipeUpRec)
        */
        
        
        
        for node in self.children {
         
            if let someItem:WorldItem = node as? WorldItem {
                setUpItem(theItem:someItem)
            } else if let someEnemy:Enemy = node as? Enemy {
                print ("found enemy node")
                setUpEnemy(theEnemy: someEnemy)
            }
        }
        
        parsePropertyList()
        
        setUpPlayer()
        
        clearStuff(theArray:clearArray)
        
        sortRewards(rewards:rewardDict)
        
        populateStats()
        
        showExistingInventory()
        
    }
    
    func setUpPlayer() {
        
        if let somePlayer:Player = self.childNode(withName: "Player") as? Player  {
            thePlayer = somePlayer
            thePlayer.physicsBody?.isDynamic = true
            thePlayer.physicsBody?.affectedByGravity = false
            thePlayer.physicsBody?.categoryBitMask = BodyType.player.rawValue
            thePlayer.physicsBody?.collisionBitMask = BodyType.item.rawValue | BodyType.enemy.rawValue | BodyType.enemyAttackArea.rawValue
            thePlayer.physicsBody?.contactTestBitMask = BodyType.item.rawValue | BodyType.enemy.rawValue | BodyType.enemyAttackArea.rawValue |  BodyType.enemyProjectile.rawValue
            thePlayer.zPosition = 0
            
            if(defaults.string(forKey: "PlayerClass") == nil) {
                
                defaults.set(playerStartingClass, forKey:"PlayerClass")
                parsePropertyListForPlayerClass(name: playerStartingClass)
                
            } else {
                
                parsePropertyListForPlayerClass(name: defaults.string(forKey: "PlayerClass")!)
            }
            
            if (defaults.string(forKey: "CurrentProjectile") != nil) {
                
                thePlayer.currentProjectile = defaults.string(forKey: "CurrentProjectile")!
            }
            
            if (defaults.integer(forKey: thePlayer.currentProjectile + "Ammo") != 0) {
                
                switchWeaponsIfNeeded(includingAddAmmo: false)
                currentProjectileAmmo = defaults.integer(forKey: thePlayer.currentProjectile + "Ammo")
                setAmmoLabel()
                
            } else {
                
                switchWeaponsIfNeeded(includingAddAmmo: true)
                
            }
            
            if (entryNode != "") {
                
                if(self.childNode(withName: entryNode) != nil) {
                    
                    thePlayer.position = (self.childNode(withName: entryNode)?.position)!
                    
                }
            }
        }
    }
    
    

    override func update(_ currentTime: TimeInterval) {
        
        
        if (cameraFollowsPlayer) {
            
            self.camera?.position = CGPoint(x: thePlayer.position.x + cameraXOffset, y: thePlayer.position.y + cameraYOffset)
        }
        
        let width:CGFloat = self.frame.width
        let height:CGFloat = self.frame.height
        
        let visibleFrame:CGRect = CGRect(x: thePlayer.position.x - (width/2), y: thePlayer.position.y - (height/2), width: width, height: height)
        
        for node in self.children {
            
            if (visibleFrame.intersects(node.frame)) {
            
                if (node is AttackArea) {
                    
                    node.position = thePlayer.position
                    
                } else if let someEnemy:Enemy = node as? Enemy {
                    
                    //check to see if enemy should move
                    if (someEnemy.moveIfPlayerWithin != -1)  {
                        
                        //look around the player to see if this enemy is near
                        if (checkCircularIntersection(withNode: someEnemy, radius: someEnemy.moveIfPlayerWithin)) {
                            
                           // print("Enemy is close!")
                            someEnemy.allowMovement = true
                            
                        } else {
                            
                           // print("Enemy is not close.")
                            someEnemy.allowMovement = false
                            
                        }
                    }
                    
                    //check to see if enemy should melee attack
                    if (someEnemy.hasMeleeAttack) {
                        
                        if (someEnemy.meleeIfPlayerWithin != -1) {
                            
                            //not -1 means we are checking a circular intersection between the player and enemy
                            if (checkCircularIntersection(withNode: someEnemy, radius: someEnemy.meleeIfPlayerWithin)) {
                                
                                //not sure why you would need to pass the meleeIfPlayerWithin member since you're passing in the node
                                someEnemy.allowMeleeAttack = true
                                
                            } else {
                                
                                someEnemy.allowMeleeAttack = false
                                
                            }
                            
                        }
                        
                    }
                    
                    //check to see if enemy should range attack
                    if (someEnemy.hasRangedAttack) {
                        
                        if (someEnemy.fireIfPlayerWIthin != -1) {
                            
                            if (checkCircularIntersection(withNode: someEnemy, radius: someEnemy.fireIfPlayerWIthin)) {
                                
                                someEnemy.allowRangedAttack = true
                                
                            } else {
                                
                                someEnemy.allowRangedAttack = false
                                
                            }
                        }
                    }
                    
                    
                    someEnemy.update(playerPos: thePlayer.position)
                    
                    //most likely the enemy will have a physics body but he might be dead, inert, etc
                    if(node.physicsBody == nil) {
                        
                        if(node.position.y > thePlayer.position.y) {
                            node.zPosition = -100
                        } else {
                            node.zPosition = 100
                        }
                    }
                    
                }
                
                else if (node is SKSpriteNode) {
                    
                    if(node.physicsBody == nil) {
                       
                        if(node.position.y > thePlayer.position.y) {
                            node.zPosition = -100
                        } else {
                            node.zPosition = 100
                        }
                    }
                    
                }
            }
        }
        
        if (walkWithPath) {
            playerUpdate()
        } else {
            playerUpdateSansPath()
        }
        
    }
    
    func checkCircularIntersection(withNode node:SKNode, radius:CGFloat) -> Bool {
        
        let deltaX = thePlayer.position.x - node.position.x
        let deltaY = thePlayer.position.y - node.position.y
        
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
        if (distance <= radius + (thePlayer.frame.size.width / 2))  {
            return true
        } else {
            return false
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    

}
