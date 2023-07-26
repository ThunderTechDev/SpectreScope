//
//  RadarScene.swift
//  SpectreScope
//
//  Created by Sergio Gonzalez Cristobal on 20/7/23.
//

import Foundation
import CoreLocation
import SpriteKit

class CompassHeading: NSObject, CLLocationManagerDelegate {
    var heading: Double = 0.0
    var perturbation: SKEmitterNode?
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.magneticHeading
        
        // Actualizar la posición de la perturbación
        let angle = heading * (.pi / 180.0) // Convertir a radianes
        let radius: CGFloat = 100 // Radio de la órbita de la perturbación
        let x = radius * cos(CGFloat(angle))
        let y = radius * sin(CGFloat(angle))
        perturbation?.position = CGPoint(x: x, y: y)
    }
}

class RadarScene: SKScene {
    let sprite = SKSpriteNode()
    let compassHeading = CompassHeading()
    
    override func didMove(to view: SKView) {
        let texture = SKTexture(imageNamed: "Radar")
        sprite.texture = texture
        sprite.size = CGSize(width: 400, height: 400)
        sprite.position = CGPoint(x: 0, y: 0)
        addChild(sprite)
        
        if let perturbation = SKEmitterNode(fileNamed: "Perturbation") {
            perturbation.position = CGPoint(x: 0, y: 100) // Inicia la perturbación en el borde del radar
            addChild(perturbation)
            compassHeading.perturbation = perturbation // Asignar la perturbación al manejador de la brújula
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Updating the Scene
    }
}
