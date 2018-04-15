//
//  GameScene_Gestures.swift
//  PlayAround
//
//  Created by Bret Williams on 1/20/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {
    
    
    func cleanUp() {
        
        for gesture in (self.view?.gestureRecognizers)! {
            self.view?.removeGestureRecognizer(gesture)
        }
    }
    
    @objc func tappedView(_ sender:UITapGestureRecognizer) {
        
        let point:CGPoint = sender.location(in: self.view)
        //print(point)
        
        if(!disableAttack) {
            if(attackAnywhere) {
                
                attack()
                
            } else {
                
                if(point.x > self.view!.bounds.width / 2)  { //to the right
                
                    attack()
                }
                
            }
        }
      
    }
    
    
    
    @objc func tappedViewDouble(_ sender:UITapGestureRecognizer) {

        let point:CGPoint = sender.location(in: self.view)
     
        if (attackAnywhere) {
            
            ranged()
            
        } else {
            
            if(point.x > self.view!.bounds.width / 2)  { //to the right
                
                ranged()
            }
            
        }
 
    }
    
    @objc func rotatedView(_ sender:UIRotationGestureRecognizer) {
        
        if(sender.state == .began) {
            print ("rotation began")
        }
        
        if(sender.state == .changed ) {
            print ("rotation changed")
            
            let rotateAmount = Measurement(value: Double(sender.rotation), unit: UnitAngle.radians).converted(to: .degrees).value
            print (rotateAmount)
            thePlayer.zRotation = -sender.rotation
        
        }
        
        if(sender.state == .ended) {
            print ("rotation ended")
        }
        
    }
    
    @objc func swipedDown() {
        
        move(theXAmount: 0, theYAmount: -100, theAnimation: "WalkForward")
        
    }
    
    
    @objc func swipedUp() {
        
        move(theXAmount: 0, theYAmount: 100, theAnimation: "WalkBackward")
        
    }
    
    @objc func swipedRight() {
        
        move(theXAmount: 100, theYAmount: 0, theAnimation: "WalkRight")
        
    }
    
    @objc func swipedLeft() {
        
        move(theXAmount: -100, theYAmount: 0, theAnimation: "WalkLeft")
        
    }
    
    
}
