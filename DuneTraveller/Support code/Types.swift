//
//  Types.swift
//  DuneTraveller
//
//  Created by Bret Williams on 12/28/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

typealias TileCoordinates = (column: Int, row: Int)



extension SKTexture {
    convenience init(pixelImageNamed: String) {
        self.init(imageNamed: pixelImageNamed)
        self.filteringMode = .nearest
    }
}
