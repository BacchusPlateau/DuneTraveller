//
//  GameScene.swift
//  DuneTraveller
//
//  Created by Bret Williams on 4/15/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//
import GameplayKit

enum BodyType:UInt32 {
    case none = 0
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
    case path = 1024
    case note = 2048
}

enum Facing:Int {
    
    case front, back, left, right, none
}

enum Direction: Int {
    case North, South, East, West
}

enum Level: Int {
    case prison = 0
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //TODO: clean this up, remove unused, and group
    
    var thePlayer:Player = Player()

    //rename this to currentSceneName
    public var currentLevel:String = "PrisonLevel1"
    
    var level: Level = .prison
    
    
    var infoLabel1:SKLabelNode = SKLabelNode()
    var infoLabel2:SKLabelNode = SKLabelNode()
    var speechIcon:SKSpriteNode = SKSpriteNode()
   
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
 
    var playerLastLocation:CGPoint = CGPoint.zero
    
    var walkTime:TimeInterval = 0
    
    var attackAnywhere:Bool = false
    var pathAlpha:CGFloat = 0.3

    var touchingDown:Bool = false
    var touchDownSprite:SKSpriteNode = SKSpriteNode()

    var offsetFromTouchDownToPlayer:CGPoint = CGPoint.zero
    
    var hasCustomPadScene:Bool = false
    
    var projectilesDict = [String : Any]()
    var prevPlayerProjectileDict = [String : Any]()

    var prevPlayerProjectileImageName:String = ""
    
    var meleeAttackButton:SKSpriteNode = SKSpriteNode()
    var rangedAttackButton:SKSpriteNode = SKSpriteNode()

    
    var diagonalAmount:CGFloat = 0
    var walkDiagonal:Bool = true
    

    
    var healthLabel:SKLabelNode = SKLabelNode()
    var armorLabel:SKLabelNode = SKLabelNode()
    var xpLabel:SKLabelNode = SKLabelNode()
    var xpLevelLabel:SKLabelNode = SKLabelNode()
    var currencyLabel:SKLabelNode = SKLabelNode()
    var classLabel:SKLabelNode = SKLabelNode()
    
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
    
    //level specific cache
    var overlay = [Overlay]()
    var encounters = [Encounter]()
    var notes = [Note]()
    var searchAreas = [SearchArea]()
    
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
        

        wallTileMap = childNode(withName: "walltiles") as? SKTileMapNode
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx:0, dy:0)
        
        setUpDatabasePath()
        
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
       
        toggleInventory()
        setUpEncounters()
        
        //can we set a tile position instead?  (6,7) ?
        thePlayer.position = CGPoint(x: -645, y: -630)
        
        fogOfWar(map: wallTileMap!, fromNode: thePlayer.position)
        
    }
    
    func fogOfWar(map: SKTileMapNode?, fromNode: CGPoint) {
        
        let (playerX,playerY) = tileCoordinates(in: map!, at: fromNode)
        var wallMatrix: [[Int]] = Array(repeating: Array(repeating: 0, count:map!.numberOfRows), count:map!.numberOfColumns)
        let maxOffset: Int = 7
  //      print("wallMatrix size = \(wallMatrix.count)")
        
        fogNode.removeAllChildren()

  //      print("Player is at \(playerX),\(playerY)")
        wallMatrix[playerX][playerY] = 3
        
        var offsetFromPlayer: Int = 1
        var x: Int = playerX
        var y: Int = playerY

        var direction: Direction = .North
    
        var x1: Int
        var x2: Int
        var y1: Int
        var y2: Int

        
        while offsetFromPlayer < maxOffset {
            
   //         print("offsetFromPlayer = \(offsetFromPlayer)")
            
            //determine bounding box for crawl
            x1 = playerX - offsetFromPlayer
            x2 = playerX + offsetFromPlayer
            y1 = playerY - offsetFromPlayer
            y2 = playerY + offsetFromPlayer
            
      //      print("x1,y1 is at \(x1),\(y1)")
      //      print("x2,y2 is at \(x2),\(y2)")
            
            direction = .North
            
            for _ in 0...(150) {
            
       //         print(" \(direction)  \(x),\(y)")
                
                //mark visited
                if wallMatrix[x][y] == 0 {
                    wallMatrix[x][y] = 2
                }
                
                //check and mark diagonals
                if (x + 1 < wallMatrix.count - 1) && (y + 1 < wallMatrix.count - 1) && wallMatrix[x+1][y+1] != 1 {
                    if tileHasBarrier(map: map, x: x+1, y: y+1) {
                        wallMatrix[x+1][y+1] = 1
                    }
                }
                
                if (x + 1 < wallMatrix.count - 1) && (y - 1 >= 0) && wallMatrix[x+1][y-1] != 1 {
                    if tileHasBarrier(map: map, x: x+1, y: y-1) {
                        wallMatrix[x+1][y-1] = 1
                    }
                }
                
                if (x - 1 >= 0) && (y + 1 < wallMatrix.count - 1) && wallMatrix[x-1][y+1] != 1 {
                    if tileHasBarrier(map: map, x: x-1, y: y+1) {
                        wallMatrix[x-1][y+1] = 1
                    }
                }
                
                if (x - 1 >= 0) && (y - 1 >= 0) && wallMatrix[x-1][y-1] != 1 {
                    if tileHasBarrier(map: map, x: x-1, y: y-1) {
                        wallMatrix[x-1][y-1] = 1
                    }
                }
                
                //check in the diretion we are heading for a barrier
                //if there is a barrier, change direction
                switch (direction) {
                case .North:
                    if y + 1 > wallMatrix.count - 1 || y > y2 {
                        direction = .East
       //                 print("north a")
                        break
                    }
                    if wallMatrix[x][y + 1] == 1 {
                        direction = .East
     //                   print("north b, y=\(y)")
                        break
                    }
                    if wallMatrix[x][y + 1] != 1 {
                        if tileHasBarrier(map: map, x: x, y: y + 1) {
                            wallMatrix[x][y + 1] = 1
                            direction = .East
     //                       print("north c, y=\(y)")
                            break
                        }
                    }
                    if y + 1 <= y2 {
                        y = y + 1
                    } else {
                        direction = .East
   //                     print("north d, y=\(y), y1=\(y2)")
                    }
                    break
                case .South:
                    if y - 1 == 0 || y - 1 < y1 {
                        direction = .West
                //        print("turn west 1, y=\(y), y1=\(y1)")
                        break
                    }
                    if wallMatrix[x][y - 1] == 1 {
                        direction = .West
              //          print("turn west 2, x=\(x), y=\(y)")
                        break;
                    }
                    if tileHasBarrier(map: map, x: x, y: y-1) {
                        wallMatrix[x][y - 1] = 1
                    }
                    if y - 1 >= y1 {
                        y = y - 1
            //            print("decrement y, y=\(y)")
                    } else {
                        direction = .West
             //           print("turn west 3, y=\(y), y1=\(y1)")
                    }
                    break;
                case .East:
                    if x + 1 > x2 || x + 1 > wallMatrix.count - 1 {
                        direction = .South
                        break
                    }
                    if wallMatrix[x + 1][y] == 1 {
                        direction = .South
                        break
                    }
                    if tileHasBarrier(map: map, x: x + 1, y: y) {
                        wallMatrix[x+1][y] = 1
                    }
                    if x + 1 <= x2 {
                        x = x + 1
                    } else {
                        direction = .South
                    }
                    break
                case .West:
                    if x - 1 == 0 || x - 1 < x1 {
                        direction = .North
                        break
                    }
                    if wallMatrix[x - 1][y] == 1 {
                        direction = .North
                        break
                    }
                    if tileHasBarrier(map: map, x: x-1, y: y) {
                        wallMatrix[x-1][y] = 1
                    }
                    if x - 1 >= x1 {
                        x = x - 1
                    } else {
                        direction = .North
                    }
                    break
                }
            }
        
            offsetFromPlayer = offsetFromPlayer + 1
        }
        
        //now for another method, this one is basically line of sight
        
        x = playerX
        y = playerY
        offsetFromPlayer = 1
        
        //north
        while offsetFromPlayer < maxOffset {
            y += 1
            if wallMatrix.count > y && tileHasBarrier(map: map, x: x, y: y) {
                wallMatrix[x][y] = 1
                break
            }
            wallMatrix[x][y] = 2
            offsetFromPlayer += 1
        }
        
        x = playerX
        y = playerY
        offsetFromPlayer = 1
        
        //south
        while offsetFromPlayer < maxOffset {
            y -= 1
            if y >= 0 && tileHasBarrier(map: map, x: x, y: y) {
                wallMatrix[x][y] = 1
                break
            }
            wallMatrix[x][y] = 2
            offsetFromPlayer += 1
        }
        
        
        x = playerX
        y = playerY
        offsetFromPlayer = 1
        
        //east
        while offsetFromPlayer < maxOffset {
            x += 1
            if wallMatrix.count > x && tileHasBarrier(map: map, x: x, y: y) {
                wallMatrix[x][y] = 1
                break
            }
            wallMatrix[x][y] = 2
            offsetFromPlayer += 1
        }
        
        x = playerX
        y = playerY
        offsetFromPlayer = 1
        
        //west
        while offsetFromPlayer < maxOffset {
            x -= 1
            if x >= 0 && tileHasBarrier(map: map, x: x, y: y) {
                wallMatrix[x][y] = 1
                break
            }
            wallMatrix[x][y] = 2
            offsetFromPlayer += 1
        }
        
        ///////////////////////////////
        
   //     printMatrix(matrix: wallMatrix)
        
        var fog: SKSpriteNode?
        
        for x in 0...wallMatrix.count - 1 {
            for y in 0...wallMatrix.count - 1 {
                
                if wallMatrix[x][y] == 0 {
                    
                    fog = SKSpriteNode()
                    fog?.position = (wallTileMap?.centerOfTile(atColumn: x, row: y))!
                    fog?.color = SKColor.black
                    fog?.zPosition = 1000
                    fog?.size = CGSize(width: 128, height: 128)
                    fogNode.addChild(fog!)
                    
                }
            }
            
        }
        
    }
    
    
    func printMatrix(matrix: [[Int]]) {
        
        
        
        for y in (0..<matrix.count).reversed() {
            
            if y < 10 {
                print("\(y) |", terminator: "")
            } else {
                print("\(y)|", terminator: "")
            }
            
            for x in 0..<matrix.count {
            
               print("\(matrix[x][y])", terminator: "")
               
            }
            
            print("")
        }
        
        print("  ", terminator: "")
        
        for _ in 0..<25 {
            print("-", terminator: "")
        }
        
        print("")
        
        print("   ", terminator: "")
        
        for x in 0..<10 {
            print("\(x)", terminator: "")
        }
        
        for x in 0..<10 {
            print("\(x)", terminator: "")
        }
        
        for x in 0..<4 {
            print("\(x)", terminator: "")
        }
        
        
    }
    
    func setUpDatabasePath() {
        
        let home = FileManager.default.homeDirectoryForCurrentUser
                
        let dbUrl = home.appendingPathComponent("ecalpon").appendingPathExtension("db")
        let dbAbsoluteString = dbUrl.path
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: dbUrl.path) {
            print("Exists")
        } else {
            print("Not exists")
        }
                
        Globals.SharedInstance.databaseUrl = dbAbsoluteString
        
        
        //test connection
        //let encounterData = EncounterData()
        //let encounter = encounterData.getEncounter(forId: 0)
        //print("Encounter name = " + encounter.name)
        
        //let overlayData = OverlayData()
        //let overlay = overlayData.getOverlayData(forLevel: 0)
        //if overlay.count > 0 {
        //    print("Overlay coords for first overlay row is (\(overlay[0].xCoordinate), \(overlay[0].yCoordinate))")
        //}
        
        //let noteData = NoteData()
        //let noteDetail = noteData.getNote(forEncounterId: 1)
        
        //print("Note message: \(noteDetail.content)")
    }
    
    func setUpEncounters() {
        
        let overlayData = OverlayData()
        overlay = overlayData.getOverlayData(forLevel: level.rawValue)
        encounters.removeAll()
        searchAreas.removeAll()
        
        let encounterData = EncounterData()
        
        overlay.forEach { item in
            
            let encounter = encounterData.getEncounter(forId: item.encounterId)
            encounters.append(encounter)
            
            switch encounter.type {
                
            case "note":
                setUpNote(forEncounter: encounter, overlayItem: item)
                
                
            case "searchArea":
                setUpSearchArea(forEncounter: encounter, overlayItem: item)
                
                
            default:
                break
                
            }
        }
        
    }
    
    func setUpNote(forEncounter encounter: Encounter, overlayItem: Overlay) {
        
        let note = SKSpriteNode(imageNamed: "note256")
        note.name = "note"
        
        //cache note data for later use
        let noteData = NoteData()
        let noteDetail = noteData.getNote(forEncounterId: encounter.id)
        notes.append(noteDetail)
        
        note.userData = NSMutableDictionary()
        note.userData?.setValue(encounter.id, forKey: "encounterId")
        
        let notePosition = CGPoint(x: overlayItem.xCoordinate, y: overlayItem.yCoordinate)
        
        //  -1,-1 puts the anchor point at the top right.   0,0 at the bottom left
        //  but this does not move the physics body!  so keep it at default which is 0.5, 0.5
        
        note.position = notePosition
        note.zPosition = 50
        
        let physicsBody = SKPhysicsBody(circleOfRadius: note.size.width / 2)
        physicsBody.isDynamic = false
        physicsBody.friction = 0
        physicsBody.allowsRotation = false
        physicsBody.restitution = 1
        physicsBody.affectedByGravity = false
        physicsBody.categoryBitMask = BodyType.note.rawValue
        
        note.physicsBody = physicsBody
        
        //must add dynamically creat sprites to wallTileMap so that it is on top of the tilemaps
        wallTileMap?.addChild(note)
 
    }
    
    func setUpSearchArea(forEncounter encounter: Encounter, overlayItem: Overlay) {
        
        //TODO:
        //we will also need to trigger a dependent encounter that will happen after this event is found
        //we will have to create a dialog box that is persistent until dismissed with a mouse click
        //we will need to load the inventory AND any notes found by encounter.typeId,
        //which in this case is the searchArea.id also
        
        let searchAreaData = SearchAreaData()
        let searchAreaDetail = searchAreaData.getSearchAreaDetail(forSearchAreaId: encounter.typeId)
        let searchArea = SearchArea()
        let (col, row) = tileCoordinates(in: wallTileMap!, at: CGPoint(x: overlayItem.xCoordinate, y: overlayItem.yCoordinate))
        
        searchArea.message = searchAreaDetail.message
        searchArea.tilePosition = CGPoint(x: col, y:row)
        searchArea.scenePosition = CGPoint(x: overlayItem.xCoordinate, y: overlayItem.yCoordinate)
        searchAreas.append(searchArea)
        
    }
    
    func setUpLevelTiles(wallTileMap: SKTileMapNode?) {
        
        guard let wallTileMap = wallTileMap else { return }
        
        for row in 0..<wallTileMap.numberOfRows {
            for col in (0..<wallTileMap.numberOfColumns).reversed() {
                
                guard let tile = tile(in: wallTileMap,
                                      at: (col, row))
                    else { continue }
                
                if tile.userData?.object(forKey: "Wall") != nil {
                    let wall = Wall()
                    wall.position = wallTileMap.centerOfTile(atColumn: col, row: row)
                    wallsNode.addChild(wall)
                  //  print("added wall at \(col),\(row)")
                }
                
                if tile.userData?.object(forKey: "Door") != nil {
                    let door = Door()
                    door.position = wallTileMap.centerOfTile(atColumn: col, row: row)
                    wallsNode.addChild(door)
                  //  print("added door at \(col),\(row)")
                }
                
            }
        }
        
      //  wallsNode.name = "Walls"
        addChild(wallsNode)
        
        fogNode = SKSpriteNode()
        addChild(fogNode)
        
        //wallTileMap.removeFromParent()
    }
    
    
    func setUpPlayer() {
        
        if let somePlayer:Player = self.childNode(withName: "Player") as? Player  {
            thePlayer = somePlayer
            thePlayer.physicsBody?.isDynamic = true
            thePlayer.physicsBody?.usesPreciseCollisionDetection = true
            thePlayer.physicsBody?.affectedByGravity = false
            thePlayer.physicsBody?.categoryBitMask = BodyType.player.rawValue
            thePlayer.physicsBody?.collisionBitMask = BodyType.item.rawValue | BodyType.enemy.rawValue | BodyType.enemyAttackArea.rawValue | BodyType.wall.rawValue | BodyType.door.rawValue | BodyType.note.rawValue
            thePlayer.physicsBody?.contactTestBitMask = BodyType.item.rawValue | BodyType.enemy.rawValue | BodyType.enemyAttackArea.rawValue |  BodyType.enemyProjectile.rawValue | BodyType.door.rawValue | BodyType.note.rawValue
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
            
            
            
            if (entryNode != "") {
                
                if(self.childNode(withName: entryNode) != nil) {
                    
                    thePlayer.position = (self.childNode(withName: entryNode)?.position)!
                    
                }
            }
        }
    }
    
    func tile(in tileMap: SKTileMapNode, at coordinates: TileCoordinates) -> SKTileDefinition? {
        
        return tileMap.tileDefinition(atColumn: coordinates.column, row: coordinates.row)
        
    }
    
    func tileCoordinates(in tileMap: SKTileMapNode, at position: CGPoint) -> TileCoordinates {
        
        let col = tileMap.tileColumnIndex(fromPosition: position)
        let row = tileMap.tileRowIndex(fromPosition: position)
        
        return (col, row)
        
    }
    
    func tileHasBarrier(map: SKTileMapNode?, x: Int, y: Int) -> Bool {
        
        var hasBarrier: Bool = false
        
        guard let tile = tile(in: map!,
                              at: (x, y))
            
            else { return hasBarrier }
        
        if (tile.userData?.object(forKey: "Wall") != nil || tile.userData?.object(forKey: "Door") != nil) {
          //  print("found door")
            hasBarrier = true
            
        }
        
        return hasBarrier
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
        

        playerUpdate()

        
    }
    
    
    
    

    
    
}
