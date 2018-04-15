//
//  GameScene_Helpers.swift
//  PlayAround
//
//  Created by Bret Williams on 1/20/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//
import Foundation
import SpriteKit

extension GameScene {

    func clearStuff(theArray:[String]) {
        
        for thing in theArray {
            defaults.removeObject(forKey: thing)
        }
        
    }
    
    func showTimer(theAnimation:String, time:TimeInterval, theItem:WorldItem) {
        
        thingBeingUnlocked = theItem.name! + "Timer"
        
        if (self.childNode(withName: theItem.name! + "Timer") == nil) {
            
            let timerNode:SKSpriteNode = SKSpriteNode(color: SKColor.clear, size: CGSize(width: 150, height:20))
            
            timerNode.position = CGPoint(x: theItem.position.x, y: theItem.position.y + theItem.frame.size.height / 2)
            timerNode.zPosition = thePlayer.zPosition + 1
            timerNode.name = theItem.name! + "Timer"
            self.addChild(timerNode)
            
            let animateAction:SKAction = SKAction(named:theAnimation, duration:time)!
            let runAction:SKAction = SKAction.run {
                
                theItem.open()
                timerNode.removeFromParent()
                self.contactWithItem(theItem: theItem)
                self.fadeOutInfoText(waitTime: theItem.infoTime)
                
            }
            
            timerNode.run(SKAction.sequence([animateAction, runAction]))
            
        }
        
        
    }
    
    
    func putWithinRange(nodeName: String) -> CGPoint {
        
        var somePoint = CGPoint.zero
        
        for node in self.children {
            
            if(node.name == nodeName) {
                
                if let rangeNode:SKSpriteNode = node as? SKSpriteNode {
                    
                    let widthVar:UInt32 = UInt32(rangeNode.frame.size.width)
                    let heightVar:UInt32 = UInt32(rangeNode.frame.size.height)
                    let randomX = arc4random_uniform( widthVar )
                    let randomY = arc4random_uniform( heightVar )
                    let frameStartX = rangeNode.position.x - (rangeNode.size.width / 2)
                    let frameStartY = rangeNode.position.y - (rangeNode.size.height / 2)
                    
                    somePoint = CGPoint(x: frameStartX + CGFloat(randomX), y:frameStartY + CGFloat(randomY))
                }
                break
            }
        }
        
        return somePoint
        
    }
    
    func showIcon(theTexture:String) {
        
        speechIcon.removeAllActions()
        speechIcon.alpha = 1
        speechIcon.isHidden = false
        
        speechIcon.texture = SKTexture(imageNamed: theTexture)
        
    }
    
    func fadeOutInfoText(waitTime:TimeInterval) {
        
        infoLabel1.removeAllActions()
        infoLabel2.removeAllActions()
        speechIcon.removeAllActions()
        
        let wait:SKAction = SKAction.wait(forDuration: waitTime)
        let fade:SKAction = SKAction.fadeAlpha(to:0, duration: 2)
        let run:SKAction = SKAction.run {
            self.infoLabel1.text = ""
            self.infoLabel2.text = ""
            self.infoLabel1.alpha = 1
            self.infoLabel2.alpha = 1
            
            self.speechIcon.alpha = 1
            self.speechIcon.isHidden = true
        }
        
        let seq:SKAction = SKAction.sequence([wait, fade, run])
        let seq2:SKAction = SKAction.sequence([wait, fade])
        
        infoLabel1.run(seq)
        infoLabel2.run(seq2)
        speechIcon.run(seq2)
        
    }
    
    
    func splitTextIntoFields(theText:String) {
        
        if(theText != "") {
        
            let maxInOneLine:Int = 25
            var i:Int = 0
            var line1:String = ""
            var line2:String = ""
            var useLine2:Bool = false
            
            
            
            for char in theText {
                
                if( i > maxInOneLine && String(char) == " ") {
                    useLine2 = true
                }
                
                if(useLine2 == false) {
                    line1 = line1 + String(char)
                } else {
                    line2 = line2 + String(char)
                }
                
                i+=1
                
            }
            
            infoLabel1.removeAllActions()
            infoLabel2.removeAllActions()
            
            infoLabel1.text = line1
            infoLabel2.text = line2
            
            infoLabel1.alpha = 1
            infoLabel2.alpha = 1
            
        }
    }
    
    
    func loadLevel(theLevel:String, toWhere:String) {
        
        if(transitionInProgress == false) {
            
            transitionInProgress = true
            
            let deviceCheck = SharedHelpers.checkIfSKSExists(baseSKSName: theLevel)
            let fullSKSNameToLoad:String = deviceCheck.0
            
            
            if let scene = GameScene(fileNamed: fullSKSNameToLoad) {
                
                //cleanUpScene()
                
                scene.currentLevel = theLevel
                scene.scaleMode = .aspectFill
                scene.entryNode = toWhere
                scene.hasCustomPadScene = deviceCheck.1
                
                let transition:SKTransition = SKTransition.fade(with:SKColor.black, duration:2)
                
                self.view?.presentScene(scene, transition:transition)
                
            }
            else {
                print("Couldnt find " + theLevel)
            }
        }
        
    }
    
    func rememberThis(withThing:String, remember:String) {
        
        defaults.set(true, forKey: currentLevel + withThing + remember)
        
        //"GrasslandVillager1alreadyContacted
        
    }
    
    func showAnimation(name: String, at point:CGPoint) {
        
      //  print("show animation name:" + name)
        
        let aniNode:SKSpriteNode = SKSpriteNode(color: SKColor.clear, size: CGSize(width: 50, height: 50))
        aniNode.position = point
        self.addChild(aniNode)
        aniNode.zPosition = 200
        
        if let animation:SKAction = SKAction(named: name) {
     //       print("running animation : " + name)
            let finishAnimation:SKAction = SKAction.run {
                 aniNode.removeFromParent()
            }
            aniNode.run(SKAction.sequence([animation, finishAnimation]))
        }
    }

}
