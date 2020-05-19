//
//  GameScene_Physics.swift
//  PlayAround
//
//  Created by Bret Williams on 1/20/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {


    //MARK: Physics contacts
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if(contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyB.node as? NonPlayerCharacter {
                contactWithNPC(theNPC: theNPC)
            }
        }else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyA.node as? NonPlayerCharacter {
                contactWithNPC(theNPC: theNPC)
            }
        }else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.door.rawValue)
        {
            thePlayer.removeAllActions()
            
            let door = contact.bodyA.node as? Door
            door?.openDoor()
            let (column, row) = tileCoordinates(in: wallTileMap!, at: (door?.position)!)
            if tile(in: wallTileMap!, at: (column, row)) != nil {
                wallTileMap!.setTileGroup(nil, forColumn: column, row: row)
        //        fogOfWar(map: wallTileMap!, fromNode: thePlayer.position)
            }
            
            print("contact with door")
         //   splitTextIntoFields(theText: "Opening this door requires a key.")
         //   fadeOutInfoText(waitTime: 33)
            
        }else if(contact.bodyB.categoryBitMask == BodyType.door.rawValue && contact.bodyA.categoryBitMask == BodyType.player.rawValue)
        {
            thePlayer.removeAllActions()
            
            let door = contact.bodyB.node as? Door
            door?.openDoor()
            let (column, row) = tileCoordinates(in: wallTileMap!, at: (door?.position)!)
            if tile(in: wallTileMap!, at: (column, row)) != nil {
                wallTileMap!.setTileGroup(nil, forColumn: column, row: row)
          //      fogOfWar(map: wallTileMap!, fromNode: thePlayer.position)
            }
            
            
            print("contact with door")
        //    splitTextIntoFields(theText: "Opening this door requires a key.")
        //    fadeOutInfoText(waitTime: 33)
        } else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.note.rawValue) {
            print("Contact with note")
            
            thePlayer.removeAllActions()
            
            let note = contact.bodyA.node
            if let noteEncounterId = note?.userData?.value(forKey: "encounterId") as? Int {
                //move this to a func, make sure to check the volatility of the encounter and set it appropriately
                if let userNote = notes.first(where: { $0.encounterId == noteEncounterId} ) {
                    splitTextIntoFields(theText: userNote.content)
                    fadeOutInfoText(waitTime: 5)
                }
            }
            
        } else if(contact.bodyB.categoryBitMask == BodyType.note.rawValue && contact.bodyA.categoryBitMask == BodyType.player.rawValue) {
            print("Contact with note")
            
            thePlayer.removeAllActions()
            
            let note = contact.bodyB.node
            if let noteEncounterId = note?.userData?.value(forKey: "encounterId") as? Int {
                //move this to a func, make sure to check the volatility of the encounter and set it appropriately
                if let userNote = notes.first(where: { $0.encounterId == noteEncounterId} ) {
                    splitTextIntoFields(theText: userNote.content)
                    fadeOutInfoText(waitTime: 5)
                }
            }
        }
        //Ranged - items
    }
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        if(contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyB.node as? NonPlayerCharacter {
          
                endContactWithNPC(theNPC: theNPC)
                
            }
        }else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyA.node as? NonPlayerCharacter {
                
                endContactWithNPC(theNPC: theNPC)
                
            }
        
        }
    }
    
    func endContactWithNPC (theNPC:NonPlayerCharacter) {
        
   //     print("endContactWithNPC")
        
        theNPC.endContactPlayer()
        fadeOutInfoText(waitTime: theNPC.infoTime)
        
    }
    
    func contactWithNPC (theNPC:NonPlayerCharacter) {
        
        if(!playerUsingPortal) {
            
            splitTextIntoFields(theText: theNPC.speak())
            theNPC.contactPlayer()
            rememberThis(withThing: theNPC.name!, remember: "alreadyContacted")
            
            if(theNPC.speechIcon != "") {
                
                showIcon(theTexture: theNPC.speechIcon)
                
            }
        }
     
    }
    
   
   
}
    
   
    
    
    
    
    

