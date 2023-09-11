//
//  TexturesModel.swift
//  SpectreScope
//
//  Created by Sergio Gonzalez Cristobal on 7/8/23.
//

import SpriteKit

struct TexturesModel {
    
    lazy var radarTextures: [SKTexture] = {
        return [
            SKTexture(imageNamed: "RadarAnimation01.png"),
            SKTexture(imageNamed: "RadarAnimation02.png"),
            SKTexture(imageNamed: "RadarAnimation03.png"),
            SKTexture(imageNamed: "RadarAnimation04.png"),
            SKTexture(imageNamed: "RadarAnimation05.png")
        ]
    }()
    
    lazy var finalTextureImage: SKTexture = {
        return SKTexture(imageNamed: "Radar.png")
    }()
    
    lazy var finalTexture: SKAction = {
        return SKAction.setTexture(finalTextureImage)
    }()
    
    lazy var phantomFaceTexture: SKTexture = {
        return SKTexture(imageNamed: "PhantomFace.png")
    }()
    
    
}
