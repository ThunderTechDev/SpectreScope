//
//  Perturbation.swift
//  SpectreScope
//
//  Created by Sergio Gonzalez Cristobal on 24/8/23.
//

import Foundation
import SpriteKit



struct Perturbation {
    var angle: CGFloat
    var radarDistance: CGFloat
    var position: CGPoint
    let entity: SKEmitterNode?
    
    init(angle: CGFloat? = nil, radarDistance: CGFloat = 190.0) {
    
        self.angle = angle ?? CGFloat.random(in: 0..<(2 * .pi))
        self.radarDistance = radarDistance
        self.entity = PerturbationFactory.createEmitterNode()
        
        let x = cos(self.angle) * self.radarDistance
        let y = sin(self.angle) * self.radarDistance
        
        self.position = CGPoint(x: x, y: y)
    }
}

struct PerturbationFactory {
    static func createEmitterNode() -> SKEmitterNode? {
        let emitter = SKEmitterNode(fileNamed: "Perturbation")
        emitter?.isHidden = true
        return emitter
    }
}


