//
//  RadarScene.swift
//  SpectreScope
//
//  Created by Sergio Gonzalez Cristobal on 20/7/23.
//

import SpriteKit

class RadarScene: SKScene {
    
    
    
    override func didMove(to view: SKView) {
        let texture = SKTexture(imageNamed: "Radar")
        let sprite = SKSpriteNode(texture: texture)
        sprite.size = CGSize(width: 400, height: 400)
        sprite.position = CGPoint(x: 0, y: 0)
        self.addChild(sprite)
    }

    override func update(_ currentTime: TimeInterval) {
        // Updating the Scene
    }
}
