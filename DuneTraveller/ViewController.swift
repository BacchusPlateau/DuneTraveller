//
//  ViewController.swift
//  DuneTraveller
//
//  Created by Bret Williams on 4/15/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "PrisonLevel1") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            } else {
                
                print("Couldn't load scene!")
            }
            
            view.ignoresSiblingOrder = true
          //  view.showsPhysics = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
}

