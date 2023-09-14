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
    
    mutating func setWhiteToCyanGradient() {
        let whiteToCyan = SKKeyframeSequence(keyframeValues: [UIColor.white, UIColor.cyan], times: [0.0, 1.0] as [NSNumber])
        entity?.particleColorSequence = whiteToCyan
        entity?.particleLifetime = 2.5
        entity?.particleLifetimeRange = 0.0
    }
    
    
    mutating func setWhiteToYellowGradient() {
        let whiteToYellow = SKKeyframeSequence(keyframeValues: [UIColor.white, UIColor.yellow], times: [0.0, 1.0] as [NSNumber])
        entity?.particleColorSequence = whiteToYellow
        entity?.particleLifetime = 2.5
        entity?.particleLifetimeRange = 0.0
    }
    
    
    mutating func setWhiteToRedGradient() {
        let whiteToRed = SKKeyframeSequence(keyframeValues: [UIColor.white, UIColor.red], times: [0.0, 1.0] as [NSNumber])
        entity?.particleColorSequence = whiteToRed
        entity?.particleLifetime = 2.5
        entity?.particleLifetimeRange = 0.0
    }
    
}


struct PerturbationFactory {
    static func createEmitterNode() -> SKEmitterNode? {
        let emitter = SKEmitterNode(fileNamed: "Perturbation")
        emitter?.particleColorBlendFactorSequence = nil
        emitter?.particleColorSequence = nil
        emitter?.isHidden = true
        return emitter
    }
}


