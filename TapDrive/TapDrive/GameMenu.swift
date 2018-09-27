//
//  GameMenu.swift
//  TapDrive
//
//  Created by Sylwester Pilarz on 27/09/2018.
//  Copyright © 2018 Intengine. All rights reserved.
//

import Foundation
import SpriteKit

class GameMenu: SKScene {
    
    var startGame = SKLabelNode()
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        startGame = self.childNode(withName: "startGame") as! SKLabelNode
    }
}
