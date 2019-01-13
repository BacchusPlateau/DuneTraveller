//
//  GameScene.swift
//  DuneTraveller
//
//  Created by Bret Williams on 4/15/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//
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
    case wall = 256
    case door = 512
}

enum Facing:Int {
    
    case front, back, left, right, none
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var thePlayer:Player = Player()
    var moveSpeed:TimeInterval = 1

    public var currentLevel:String = "PrisonLevel1"
    
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
    
    var destinationPoint:CGPoint = CGPoint.zero
    
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
    var dynamicSprite:SKSpriteNode = SKSpriteNode()
    
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
    var inventoryVisible:Bool = true
    var wallsNode = SKNode()
    var wallTileMap: SKTileMapNode?
    var fogNode:SKSpriteNode = SKSpriteNode()
    
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
    
    override func didMove(to view: SKView) {
        
     //   print ("didMove")
        wallTileMap = childNode(withName: "walltiles") as? SKTileMapNode
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx:0, dy:0)
        
        self.enumerateChildNodes(withName: "//*") {
            node, stop in
            
            if let theCamera:SKCameraNode = node as? SKCameraNode {
                
                
              //  print("found camera")
                
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
          
                for i in 1...30 {
                    
                    if (theCamera.childNode(withName: "Slot" + String(i)) is SKSpriteNode) {
                        
                        self.availableInventorySlots.append("Slot" + String(i))
                        
                    }
                }
                stop.pointee = true  //halt transversal of node tree
            }
        }
    
        
        for node in self.children {
            
            if let someItem:WorldItem = node as? WorldItem {
                setUpItem(theItem:someItem)
            } else if let someEnemy:Enemy = node as? Enemy {
                setUpEnemy(theEnemy: someEnemy)
            }
        }
        
        setUpLevelTiles(wallTileMap: wallTileMap)
        parsePropertyList()
        setUpPlayer()
        clearStuff(theArray:clearArray)
        sortRewards(rewards:rewardDict)
        populateStats()
        showExistingInventory()
        toggleInventory()
        fogOfWar(map: wallTileMap!, fromNode: thePlayer.position)
        
    }
    
    func fogOfWar(map: SKTileMapNode?, fromNode: CGPoint) {
        
        return
        
        let (x,y) = tileCoordinates(in: map!, at: fromNode)
  //      var fog: SKSpriteNode?
  //      var offset = 1
        var wallMatrix: [[Int]] = Array(repeating: Array(repeating: 0, count:map!.numberOfRows), count:map!.numberOfColumns)
        var fogMatrix: [[Int]] = Array(repeating: Array(repeating: 0, count:map!.numberOfRows), count:map!.numberOfColumns)
        
        fogNode.removeAllChildren()

        print("Player is at \(x),\(y)")

        for child in wallsNode.children {
            
            if let node = child as? SKSpriteNode {
                
                let (row,col) = tileCoordinates(in: map!, at: node.position)
                wallMatrix[row][col] = 1
                
            }
            
        }

        

        /*
                
        while offset < map!.numberOfColumns {
                    
            let tileUp = tile(in: map!, at: (x, y+offset))
            let tileUpRight = tile(in: map!, at: (x+offset, y+offset))
            let tileRight = tile(in: map!, at: (x+offset, y))
            let tileDownRight = tile(in: map!, at: (x+offset, y-offset))
            let tileDown = tile(in: map!, at: (x, y-offset))
            let tileDownLeft = tile(in: map!, at: (x-offset, y-offset))
            let tileLeft = tile(in: map!, at: (x-offset, y))
            let tileUpLeft = tile(in: map!, at: (x-offset, y+offset))
            
            offset = offset + 1
            
        }
 */
        
    }
    
    func fogOfWar2(map: SKTileMapNode?, fromNode: CGPoint) {
        
        //remove all nodes from fogNode set to reset it
        //given a col, row from the fromNode, blank out all tiles that are hidden from view
        //iterate in four cardinal directions on the map, creating black sprites on the fogNode sprite set
        
        let (x,y) = tileCoordinates(in: map!, at: fromNode)
        var fog: SKSpriteNode?
        
        //TODO remove all notes from fogNode
        fogNode.removeAllChildren()
        
        print("Player is at \(x),\(y)")
        
        //check east
        for col in (x..<map!.numberOfColumns) {
            for row in 0..<map!.numberOfRows {
                
                guard let tile = tile(in: map!,
                                      at: (col, row))
                    else { continue }
                
                if (tile.userData?.object(forKey: "Wall") != nil || tile.userData?.object(forKey: "Door") != nil) {
                    
                    for barrier in (col+1..<map!.numberOfColumns) {
                        
                        //if this is a border wall don't fog it
                        fog = SKSpriteNode()
                        fog?.position = (wallTileMap?.centerOfTile(atColumn: barrier, row: row))!
                        fog?.color = SKColor.black
                        fog?.zPosition = 100
                        fog?.size = CGSize(width: 128, height: 128)
                        fogNode.addChild(fog!)
                        print("Added fog at \(barrier),\(row)")
                        
                    }
                    
                }
            }
        }
        
    }
    
    func setUpLevelTiles(wallTileMap: SKTileMapNode?) {
        
        guard let wallTileMap = wallTileMap else { return }
        
        for row in 0..<wallTileMap.numberOfRows {
            for col in 0..<wallTileMap.numberOfColumns {
                
                guard let tile = tile(in: wallTileMap,
                                      at: (col, row))
                    else { continue }
                
                if tile.userData?.object(forKey: "Wall") != nil {
                    let wall = Wall()
                    wall.position = wallTileMap.centerOfTile(atColumn: col, row: row)
                    wallsNode.addChild(wall)
                   // print("added wall at \(col),\(row)")
                }
                
                if tile.userData?.object(forKey: "Door") != nil {
                    let door = Door()
                    door.position = wallTileMap.centerOfTile(atColumn: col, row: row)
                    wallsNode.addChild(door)
                    print("added door at \(col),\(row)")
                }
                
            }
        }
        
        wallsNode.name = "Walls"
        addChild(wallsNode)
        
        fogNode = SKSpriteNode()
        addChild(fogNode)
        
        //wallTileMap.removeFromParent()
    }
    
    
    func setUpPlayer() {
        
        if let somePlayer:Player = self.childNode(withName: "Player") as? Player  {
            thePlayer = somePlayer
            thePlayer.physicsBody?.isDynamic = true
            thePlayer.physicsBody?.affectedByGravity = false
            thePlayer.physicsBody?.categoryBitMask = BodyType.player.rawValue
            thePlayer.physicsBody?.collisionBitMask = BodyType.item.rawValue | BodyType.enemy.rawValue | BodyType.enemyAttackArea.rawValue | BodyType.wall.rawValue | BodyType.door.rawValue
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
    
    func tile(in tileMap: SKTileMapNode, at coordiates: TileCoordinates) -> SKTileDefinition? {
        
        return tileMap.tileDefinition(atColumn: coordiates.column, row: coordiates.row)
        
    }
    
    func tileCoordinates(in tileMap: SKTileMapNode, at position: CGPoint) -> TileCoordinates {
        
        let col = tileMap.tileColumnIndex(fromPosition: position)
        let row = tileMap.tileRowIndex(fromPosition: position)
        
        return (col, row)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    
        if (cameraFollowsPlayer) {
            
            self.camera?.position = CGPoint(x: thePlayer.position.x + cameraXOffset, y: thePlayer.position.y + cameraYOffset)
        }
        
        let width:CGFloat = self.frame.width
        let height:CGFloat = self.frame.height
        
        let visibleFrame:CGRect = CGRect(x: thePlayer.position.x - (width/2),
                                         y: thePlayer.position.y - (height/2),
                                         width: width,
                                         height: height)
        
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
    
    
    
    

    
    
}
