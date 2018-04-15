//
//  GameScene_Inventory.swift
//  PlayAround
//
//  Created by Bret Williams on 2/10/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {

    func sortRewards( rewards: [String:Any]) {
        
        for (key, value) in rewards {
            
            switch key {
            case "Health":
                
                if (value is Int) {
                    addToHealth(amount: value as! Int)
                }
                
            case "Armor":
                
                if (value is Int) {
                    addToArmor(amount: value as! Int)
                }
                
            case "Projectile":
                
                if (value is String) {
             //       print("Got a new projectile!")
                    thePlayer.currentProjectile = value as! String
                    switchWeaponsIfNeeded(includingAddAmmo:true)
                }
                
            case "XP":
                
                if (value is Int) {
                    addToXP(amount: value as! Int)
                }
                
            case "Currency":
                
                if (value is Int) {
                    addCurrency(amount: value as! Int)
                }
                
            case "Ammo":
                
                if (value is Int) {
                    addToAmmo(amount: value as! Int)
                }
                
            case "Class":
                
                if (value is String) {
                    parsePropertyListForPlayerClass(name: value as! String)
                }
                
                
            default:
                // MARK  is this correct?
                print ("sortRewards: key = " + key)
                if (value is Int) {
                    
                    addToInventory(newInventory: key, amount: value as! Int)
                    checkForInventoryIcon(name: key, amount: defaults.integer(forKey: key))
                }
            }
            
        }
        
    }
    
    func addToHealth(amount:Int) {
        
        currentHealth += amount
        if (currentHealth > thePlayer.health) {
            currentHealth = thePlayer.health
        }
        setHealthLabel()
        
    }
    
    func addToArmor(amount:Int) {
        
        currentArmor += amount
        if (currentArmor > thePlayer.armor) {
            currentArmor = thePlayer.armor
        }
        setArmorLabel()
        
    }
    
    func subtractHealth(amount: Int) {
        
        currentHealth -= amount
        if(currentHealth <= 0) {
            currentHealth = 0
            killPlayer()
        }
        
        defaults.set(currentArmor, forKey: "CurrentHealth")
        setHealthLabel()
        
    }
    
    func subtractArmor(amount: Int) {
        
        currentArmor -= amount
        if (currentArmor < 0) {
            currentArmor = 0
        }
        
        defaults.set(currentArmor, forKey: "CurrentArmor")
        setArmorLabel()
        
    }
    
    func addCurrency(amount:Int) {
        
        currency += amount
        defaults.set(currency, forKey:"Currency")
        setCurrencyLabel()
        
    }
    
    func addToXP(amount:Int) {
        
        currentXP += amount
        if (currentXP >= maxXP) {
            
            xpLevel += 1
            retrieveXPData()
            currentXP = 0
            defaults.set(xpLevel, forKey: "XPLevel")
        }
        
        defaults.set(currentXP, forKey: "CurrentXP")
        setXPLabel()
        
    }
    
    func subtractAmmo(amount: Int) {
        
        if (currentProjectileAmmo > 0)  {
            
            currentProjectileAmmo -= amount
            defaults.set(currentProjectileAmmo, forKey: thePlayer.currentProjectile + "Ammo")
            setAmmoLabel()
            
            if (currentProjectileAmmo <= 0) {
                
                currentProjectileAmmo = 0
                defaults.set(0, forKey: thePlayer.currentProjectile + "Ammo")
             
                if (thePlayer.defaultProjectile != "" && thePlayer.defaultProjectile != thePlayer.currentProjectile) {
                    
                    defaults.set(thePlayer.defaultProjectile, forKey:"CurrentProjectile")
                    thePlayer.currentProjectile = thePlayer.defaultProjectile
                    switchWeaponsIfNeeded(includingAddAmmo: false)
                    currentProjectileAmmo = defaults.integer(forKey: thePlayer.currentProjectile + "Ammo")
                    setAmmoLabel()
                    
                }
            }
        }
    }
    
    func addToAmmo(amount:Int) {
        
        if (defaults.integer(forKey: thePlayer.currentProjectile + "Ammo") != 0) {
            
       //     print("Already had some ammo, so add to it")
            currentProjectileAmmo = defaults.integer(forKey: thePlayer.currentProjectile + "Ammo")
            currentProjectileAmmo += amount
        } else {
            
       //     print("had zero ammo, so adding whatever was passed in")
            currentProjectileAmmo = amount
            
        }
        
        defaults.set(currentProjectileAmmo, forKey: thePlayer.currentProjectile + "Ammo")
        setAmmoLabel()
        
    }
    
    func addToInventory (newInventory:String, amount:Int) {
        
        if(defaults.integer(forKey: newInventory) != 0) {
            
            let currentAmount:Int = defaults.integer(forKey:newInventory)
            let newAmount:Int = currentAmount + amount
            
            print ("set \(newAmount) for \(newInventory)")
            
            defaults.set(newAmount, forKey:newInventory)
            checkForItemThatMightOpen(newInventory: newInventory, amount: newAmount)
            
        } else {
            
            print ("set \(amount) for \(newInventory)")
            
            defaults.set(amount, forKey:newInventory)
            checkForItemThatMightOpen(newInventory: newInventory, amount: amount)
            
        }
        
    }
    
    func showExistingInventory() {
        
        
        let path = Bundle.main.path(forResource:"GameData", ofType: "plist")
        let dict:NSDictionary = NSDictionary(contentsOfFile: path!)!
        if (dict.object(forKey: "Inventory") != nil) {
            if let inventoryDict:[String:Any] = dict.object(forKey: "Inventory") as? [String:Any] {
                
                for (key,_) in inventoryDict {
                    
                    if (defaults.integer(forKey: key) > 0) {
                        
                        checkForInventoryIcon(name: key, amount: defaults.integer(forKey: key))
                    }
                }
  
            }
        }
    }
    
    func checkForInventoryIcon(name: String, amount: Int) {
        
        //check to see if there is already an icon showing for this inventory.  if yes update it
        if (self.camera?.childNode(withName: name + "Icon") != nil) {
            
            if let existingIcon:Inventory = self.camera?.childNode(withName: name + "Icon") as? Inventory {
                //update existing one
                existingIcon.theCount = amount
                existingIcon.updateLabel()
            }
        } else {
            
            //if not now, we look in the property list for info on the inventory to create a new one
            checkForInventoryDataInPropertyList(name: name, amount: amount)
        }
        
    }
    
    func checkForInventoryDataInPropertyList(name:String, amount:Int) {
        
        let path = Bundle.main.path(forResource:"GameData", ofType: "plist")
        let dict:NSDictionary = NSDictionary(contentsOfFile: path!)!
        if (dict.object(forKey: "Inventory") != nil) {
            if let inventoryDict:[String:Any] = dict.object(forKey: "Inventory") as? [String:Any] {
                
                for (key,value) in inventoryDict {
                    
                    if (key == name) {
                        
                        if (value is [String:Any]) {
                            
                            createInventoryIcon(name: name, amount: amount, theDict: value as! [String:Any])
                        }
                        break
                    }
                }
                
            }
            
        }
        
        
    }
    
    func createInventoryIcon( name: String, amount: Int, theDict: [String:Any])  {
        
        var imageName:String = ""
        
        for (key,value) in theDict {
            
            if (key == "Icon") {
                
                if (value is String) {
                    
                    imageName = value as! String
                }
                
                break
            }
        }
        
        if (imageName != "") {
            
            let newInventory:Inventory = Inventory(imageNamed: imageName)
            newInventory.theCount = amount
            newInventory.name = name + "Icon"
            newInventory.setUpWithDict(theDict: theDict)
            self.camera?.addChild(newInventory)
            let availableSlot:String = findAvailableSlotPlacement()
            
            if (self.camera?.childNode(withName: availableSlot) != nil)  {
                
                newInventory.position = (self.camera?.childNode(withName: availableSlot)?.position)!
                newInventory.zPosition = (self.camera?.childNode(withName: availableSlot)?.zPosition)!
            }
            
        }
        
    }
    
    func findAvailableSlotPlacement() -> String {
        
        var emptySpot:String = ""
        if (availableInventorySlots.count > 0) {
            
            emptySpot = availableInventorySlots[0]
            availableInventorySlots.remove(at: 0)
        }
        
        print ("Empty Slot: " + emptySpot)
        
        return emptySpot
    }
    
    func checkForItemThatMightOpen( newInventory:String, amount:Int) {
        
        for node in self.children {
            
            if let theItem:WorldItem = node as? WorldItem {
                
                if (!theItem.isOpen) {
                    
                    if (newInventory == theItem.requiredThing) {
                        
                        if (amount >= theItem.requiredAmount) {
                            
                            if (theItem.unlockedTextArray.count > 0) {
                                
                                splitTextIntoFields(theText: theItem.getUnlockedInfo())
                                theItem.open()
                                
                                if(theItem.unlockedIcon != "") {
                                    
                                    showIcon(theTexture: theItem.unlockedIcon)
                                    
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        
        
    }

    func populateStats() {
        
        if (defaults.integer(forKey: "CurrentHealth") != 0) {
            currentHealth = defaults.integer(forKey: "CurrentHealth")
        } else {
            currentHealth = thePlayer.health
            defaults.set(currentHealth, forKey: "CurrentHealth")
        }
        
        if (defaults.integer(forKey: "CurrentArmor") != 0) {
            currentHealth = defaults.integer(forKey: "CurrentArmor")
        } else {
            currentArmor = thePlayer.armor
        }
        if (defaults.integer(forKey: "Currency") != 0) {
            currency = defaults.integer(forKey: "Currency")
        } else {
            currency = 0
        }
        if (defaults.integer(forKey: "XPLevel") != 0) {
            xpLevel = defaults.integer(forKey: "XPLevel")
        } else {
            xpLevel = 0
        }
        if (defaults.integer(forKey: "CurrentXP") != 0) {
            currentXP = defaults.integer(forKey: "CurrentXP")
        } else {
            currentXP = 0
        }
        
        retrieveXPData()
        
        setXPLabel()
        setHealthLabel()
        setArmorLabel()
        setCurrencyLabel()
        
    }
    
    func setClassLabel() {
        
        if (defaults.string(forKey: "PlayerClass") != nil) {
            classLabel.text = defaults.string(forKey: "PlayerClass")
        }
        
    }
    
    
    func setXPLabel() {
        
        xpLabel.text = String(currentXP) + "/" + String(maxXP)
    }
    
    func setCurrencyLabel()  {
        
        currencyLabel.text = String(currency)
    }
    
    func setAmmoLabel() {
        
        if (currentProjectileRequiresAmmo) {
            ammoLabel.text = String(currentProjectileAmmo)
        } else {
            ammoLabel.text = "N/A"
        }
    }
    
    func setArmorLabel() {
        
        armorLabel.text = String(currentArmor) + "/" + String(thePlayer.armor)
        
    }
    
    func setHealthLabel() {
        
        healthLabel.text = String(currentHealth) + "/" + String(thePlayer.health)
        
    }
    
    func retrieveXPData() {
        
        if (xpArray.count == 0 || xpLevel >= xpArray.count) {
            return
        }
        
        let xpDict:[String:Any] = xpArray[xpLevel]
        
        for (key,value) in xpDict {
            
            switch key {
            case "Name":
                if (value is String) {
                    xpLevelLabel.text = value as? String
                }
            case "Max":
                if(value is Int) {
                    maxXP = value as! Int
                }
            default:
                continue
            }
            
        }
        
    }

    func removeInventoryIcon(name:String) {
        
        if (self.camera?.childNode(withName: name + "Icon") != nil)  {
            
            if let existingIcon:Inventory = self.camera?.childNode(withName: name + "Icon") as? Inventory {
                
                if (existingIcon.slotUsed != "") {
                    
                    availableInventorySlots.append(existingIcon.slotUsed)
                }
                
                existingIcon.removeFromParent()
            }
            
            
        }
    }

}
