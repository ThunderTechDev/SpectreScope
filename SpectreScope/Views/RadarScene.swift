//
//  RadarScene.swift
//  SpectreScope
//
//  Created by Sergio Gonzalez Cristobal on 20/7/23.
//

import Foundation
import CoreLocation
import SpriteKit
import AVFoundation

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
    var perturbation: SKEmitterNode?
    var audioPlayer: AVAudioPlayer?

    override func didMove(to view: SKView) {
        // Cargar las imágenes de la animación del radar
        let radarTextures = [
            SKTexture(imageNamed: "RadarAnimation01.png"),
            SKTexture(imageNamed: "RadarAnimation02.png"),
            SKTexture(imageNamed: "RadarAnimation03.png"),
            SKTexture(imageNamed: "RadarAnimation04.png"),
            SKTexture(imageNamed: "RadarAnimation05.png")
        ]
        
        // Crear una acción de animación
        let radarAnimation = SKAction.animate(with: radarTextures, timePerFrame: 0.02)
        
        // Crear una acción para mostrar la textura final
        let finalTexture = SKAction.setTexture(SKTexture(imageNamed: "Radar.png"))

        // Crear acciones para hacer desaparecer y aparecer la perturbación
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let hidePerturbation = SKAction.run { [weak self] in self?.perturbation?.run(fadeOut) }
        let showPerturbation = SKAction.run { [weak self] in self?.perturbation?.run(fadeIn) }

        // Crear una acción de espera
        let wait = SKAction.wait(forDuration: 1.0) // Esperar 1 segundo

        // Crear una acción para reproducir el sonido
        let playSound = SKAction.run { [weak self] in
            self?.audioPlayer?.volume = 0.04
            self?.audioPlayer?.play()
        }

        // Crear una secuencia de acciones: animación, mostrar textura final, ocultar perturbación, esperar, mostrar perturbación
        let sequence = SKAction.sequence([showPerturbation, radarAnimation, hidePerturbation, playSound, finalTexture, wait])

        // Crear una acción que repita la secuencia indefinidamente
        let repeatAnimation = SKAction.repeatForever(sequence)

        // Aplicar la acción al sprite
        sprite.run(repeatAnimation)

        sprite.size = CGSize(width: 400, height: 400)
        sprite.position = CGPoint(x: 0, y: 0)
        addChild(sprite)

        if let perturbation = SKEmitterNode(fileNamed: "Perturbation") {
            self.perturbation = perturbation
            perturbation.position = CGPoint(x: 0, y: 100) // Inicia la perturbación en el borde del radar
            addChild(perturbation)
            compassHeading.perturbation = perturbation // Asignar la perturbación al manejador de la brújula
        }

        if let url = Bundle.main.url(forResource: "Tap", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            } catch {
                print("No se pudo cargar el archivo de sonido.")
            }
        }
    }


    
    override func update(_ currentTime: TimeInterval) {
        // Updating the Scene
    }
}
