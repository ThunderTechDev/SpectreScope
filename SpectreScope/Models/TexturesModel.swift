//
//  TexturesModel.swift
//  SpectreScope
//
//  Created by Sergio Gonzalez Cristobal on 7/8/23.
//

import SpriteKit

struct TexturesModel {
    
    let radarTextures = [
        SKTexture(imageNamed: "RadarAnimation01.png"),
        SKTexture(imageNamed: "RadarAnimation02.png"),
        SKTexture(imageNamed: "RadarAnimation03.png"),
        SKTexture(imageNamed: "RadarAnimation04.png"),
        SKTexture(imageNamed: "RadarAnimation05.png")
    ]
    
    let finalTexture = SKAction.setTexture(SKTexture(imageNamed: "Radar.png"))
    
}
