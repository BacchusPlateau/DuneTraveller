//
//  GameScene_PropertyList.swift
//  PlayAround
//
//  Created by Bret Williams on 1/20/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {

    //MARK: Parse PList
    
    func parsePropertyList() {
        
        let path = Bundle.main.path(forResource:"GameData", ofType: "plist")
        let dict:NSDictionary = NSDictionary(contentsOfFile: path!)!
        
        if (dict.object(forKey: "Settings") != nil) {
            
            if let settingsDict:[String:Any] = dict.object(forKey: "Settings") as? [String:Any] {
                sortSettings(theDict:settingsDict)
            }
        }
        
        if (dict.object(forKey: "Projectiles") != nil) {
            
            if let projDict:[String:Any] = dict.object(forKey: "Projectiles") as? [String:Any] {
                projectilesDict = projDict
   //             print("found projectiles dict and set it")
            }
        }
        
        if (dict.object(forKey: "XP") != nil) {
            
            if let xpData:[[String:Any]] = dict.object(forKey: "XP") as? [[String:Any]] {
                
                xpArray = xpData
            }
        }
        
        if(dict.object(forKey: "Levels") != nil) {
            
            if let levelDict:[String : Any] = dict.object(forKey: "Levels") as? [String: Any]
            {
                for(key, value) in levelDict {
                    
                    if(key == currentLevel) {
                        
                        if let levelData:[String:Any] = value as? [String:Any] {
                            
                            for(key,value) in levelData {
                                if (key == "NPC") {
                                    
                                    createNPCwithDict(theDict:value as! [String:Any])
                                }
                                
                                if (key == "Properties") {
                                    
                                    parseLevelSpecificProperties(theDict:value as! [String:Any])
                                }
                                
                                if (key == "Rewards") {
                                    
                                    if (value is [String:Any]) {
                                        
                                        rewardDict = value as! [String:Any]
                                    }
                                    
                                }
                                
                                if (key == "Clear") {
                                    
                                    if (value is [String]) {
                                        
                                        clearArray = value as! [String]
                                    }
                                }
                                
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func sortSettings(theDict:[String:Any])  {
        
        for (key,value) in theDict {
            
            switch key {
            case "PathAlpha":
                if(value is CGFloat) {
                    pathAlpha = value as! CGFloat
                }
            case "WalkWithPath":
                if(value is Bool) {
                    walkWithPath = value as! Bool
                }
            case "AttackAnywhere":
                if(value is Bool) {
                    attackAnywhere = value as! Bool
                }
            case "WalkDiagonal":
                if(value is Bool) {
                    walkDiagonal = value as! Bool
                }
            case "PlayerStartngClass":
                if(value is String) {
                    playerStartingClass = value as! String
                }
            default:
                continue
            }
            
        }
        
        
    }
    
    func parseLevelSpecificProperties ( theDict: [String:Any]) {
        
        for(key, value) in theDict {
         //   print (key)
            switch key {
            case "CameraFollowsPlayer":
                if(value is Bool) {
                    cameraFollowsPlayer = value as! Bool
                }
            case "CameraOffset":
                if(value is String) {
                    let somePoint:CGPoint = CGPointFromString(value as! String)
                    cameraXOffset = somePoint.x
                    cameraYOffset = somePoint.y
                }
            case "ContinuePoint":
             //   print ("here")
                if(value is Bool) {
                    if(value as! Bool == true) {
                        defaults.set(currentLevel, forKey: key)
                //        print(currentLevel + " " + key)
                    }
                }
                
            case "DisableAttack":
                if(value is Bool) {
                    if(value as! Bool == true) {
                        disableAttack = value as! Bool
                    }
                }
            default:
                continue
            }
        }
        
    }
    
    func createNPCwithDict( theDict: [String:Any]) {
        
        for(key, value) in theDict {
            
            var theBaseImage : String = ""
            var theRange : String = ""
            let nickName: String = key
            
            var alreadyFoundNPCinScene:Bool = false
            
            for node in self.children {
                
                if(node.name == key) {
                    
                    if (node is NonPlayerCharacter) {
                        
                        useDictWithNPC(theDict: value as! [String:Any], theNPC: node as! NonPlayerCharacter)
                        alreadyFoundNPCinScene = true
                        
                    }
                }
            }
            
            if(!alreadyFoundNPCinScene) {
                
                if let NPCData:[String:Any] = value as? [String:Any] {
                    for (key,value) in NPCData {
                        if(key == "BaseImage") {
                            theBaseImage = value as! String
                        } else if (key == "Range") {
                            theRange = value as! String
                        }
                    }
                }
            
            
                if let NPCData:[String : Any] = value as? [String : Any] {
                    
                    for (key, value) in NPCData {
                        
                        if (key == "BaseImage") {
                            
                            theBaseImage = value as! String
            
                        } else  if (key == "Range") {
                            
                            theRange = value as! String
                        }
                    }
                }
                
                let newNPC:NonPlayerCharacter = NonPlayerCharacter(imageNamed: theBaseImage)
                newNPC.name = nickName
                newNPC.baseFrame = theBaseImage
                newNPC.setUpWithDict(theDict: value as! [String: Any])
                self.addChild(newNPC)
                newNPC.zPosition = thePlayer.zPosition - 1
                newNPC.position = putWithinRange(nodeName: theRange)
                newNPC.alreadyContacted = defaults.bool(forKey: currentLevel + nickName + "alreadyContacted")
            }
        }
    }
    
    func useDictWithNPC(theDict:[String:Any], theNPC:NonPlayerCharacter) {
        
        theNPC.setUpWithDict(theDict: theDict)
        
        for (key,value) in theDict {
            
            if (key == "Range") {
                
                theNPC.position = putWithinRange(nodeName: value as! String)
                
            }
        }
        
        theNPC.alreadyContacted = defaults.bool(forKey: currentLevel + theNPC.name! + "alreadyContacted")
        
    }
    
    func setUpEnemy(theEnemy:Enemy) {
        
        var foundEnemyInLevelDict:Bool = false
        let path = Bundle.main.path(forResource: "GameData", ofType: "plist")
        let dict:NSDictionary = NSDictionary(contentsOfFile: path!)!
        
        if (dict.object(forKey: "Levels") != nil) {
            
            if let levelDict:[String:Any] = dict.object(forKey: "Levels") as? [String:Any] {
                
                for (key,value) in levelDict  {
                    
                    if (key == currentLevel) {
                        
                        if let levelData:[String:Any] = value as? [String:Any] {
                            
                            for (key,value) in levelData {
                                
                                if (key == "Enemies") {
                                    print ("Found Enemies!")
                                    if let itemsData:[String:Any] = value as? [String:Any] {
                                        
                                        for (key,value) in itemsData {
                                            
                                            if (key == theEnemy.name) {
                                                print ("Found enemy in level dict!")
                                                foundEnemyInLevelDict = true
                                                useDictWithEnemy(theDict: value as! [String:Any], theEnemy: theEnemy)
                                                
                                                break
                                            } //if
                                        } //for
                                    }  //if let
                                    break
                                } //if
                            } //for
                        } //if let
                        break
                    } //if
                } //for
            } //if let
        } //if
        
        
        if ( foundEnemyInLevelDict == false) {
            
            if (dict.object(forKey: "Enemies") != nil) {
                
                if let itemsData:[String : Any] = dict.object(forKey: "Enemies") as? [String : Any] {
                    
                    for (key, value) in itemsData {
                        
                        if ( key == theEnemy.name) {
                            
                            useDictWithEnemy(theDict: value as! [String : Any], theEnemy: theEnemy)
                            
                            //print ("Found \(key) to setup with property list data in Root")
                            
                            break
                        }
                    
                    }
                
                }
              
            }
            
        }
        
    }
    
    func useDictWithEnemy(theDict:[String:Any], theEnemy:Enemy) {
        
        theEnemy.setUpEnemy(theDict:theDict)
        
    }
    
    func setUpItem(theItem:WorldItem) {
        
    //    print("setUpItem: \(theItem.name!)")
        
        let path = Bundle.main.path(forResource:"GameData", ofType: "plist")
        let dict:NSDictionary = NSDictionary(contentsOfFile: path!)!
        var foundItemInLevel:Bool = false
        
        if(dict.object(forKey: "Levels") != nil) {
            
            if let levelDict:[String : Any] = dict.object(forKey: "Levels") as? [String: Any]
            {
                for(key, value) in levelDict {
                    
                 //   print("key = \(key), currentLevel = \(currentLevel)")
                    
                    if(key == currentLevel) {
                        
                        if let levelData:[String:Any] = value as? [String:Any] {
                           
                            for(key,value) in levelData {
                                
                       //         print("key in levelData = \(key), \(value)")
                                
                                if (key == "Items")  {
                                  
                                    if let itemsData:[String:Any] = value as? [String:Any] {
                                        
                                        for(key,value) in itemsData {
                                            
                                   //         print("key in itemsData = \(key)")
                                            
                                            if(key == theItem.name) {
                                                
                                                foundItemInLevel = true
                                        //        print ("found \(key) to setup with propertylist data")
                                                useDictWithWorldItem(theDict: value as! [String:Any], theItem: theItem)
                                      
                                                break
                                            } // if key == item name
                                            
                                        } //for key,value in items data
                                    } //if let items data
                                    break
                                } //if key = items
                                
                            } //for key, value in level data
                        }
                        break
                    }
                    
                }
                
            }
        }
        
        if(foundItemInLevel == false) {
            
            if(dict.object(forKey: "Items") != nil) {
                
                if let itemsData:[String : Any] = dict.object(forKey: "Items") as? [String: Any]
                {
                    
                    for(key,value) in itemsData {
//print("key = \(key)")
                        if(key==theItem.name) {
                            
                            useDictWithWorldItem(theDict: value as! [String:Any], theItem: theItem)
                            
                         //   print ("found \(key) to setup with propertylist data in Root")
                            break
                        }
                        
  
                    }
                }
            }
        }
    }
    
    func useDictWithWorldItem( theDict:[String:Any], theItem:WorldItem)     {
        
        theItem.setUpWithDict(theDict: theDict)
  
    }
    
    // MARK: Player Parsing

    
    func parsePropertyListForPlayerClass(name:String) {
        
        let path = Bundle.main.path(forResource:"GameData", ofType: "plist")
        let dict:NSDictionary = NSDictionary(contentsOfFile: path!)!
        if(dict.object(forKey: "Class") != nil) {
            
            if let classDict:[String:Any] = dict.object(forKey: "Class") as? [String:Any] {
                
                for (key,value) in classDict {
                    
                    if(key == name) {
                        
                        defaults.set(name, forKey: "PlayerClass")
                        thePlayer.setUpWithDict(theDict: value as! [String:Any])
                        playerFacing = .front
                        runIdleAnimation()  
                        setClassLabel()
                        break
                        
                    }
                }
            }
        }
    }
    
    
    
    
    
    
}









