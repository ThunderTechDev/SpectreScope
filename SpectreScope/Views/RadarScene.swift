//
//  RadarScene.swift
//  SpectreScope
//
//  Created by Sergio Gonzalez Cristobal on 20/7/23.
//

import SwiftUI
import SpriteKit
import AVFoundation


class RadarScene: SKScene {
    let sprite = SKSpriteNode()
    var compassHeading: CompassHeading?
    @ObservedObject var viewModel = RadarViewModel()
    @Published var isPerturbationVisible: Bool = false
    var audioPlayer: AVAudioPlayer?
    var texturesModel = TexturesModel()
    
 
    // Provisional Labels
    let decibelLevelLabel = SKLabelNode(fontNamed: "Arial")
    let silenceDurationLabel = SKLabelNode(fontNamed: "Arial")
    

    override func didMove(to view: SKView) {
        
        
      
        
        
        compassHeading = CompassHeading(viewModel: viewModel)
        
        // Crear una acción de animación
        let radarAnimation = SKAction.animate(with: texturesModel.radarTextures, timePerFrame: 0.02)
        
        // Crear acciones para hacer desaparecer y aparecer la perturbación
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let hidePerturbation = SKAction.run { [weak self] in self?.viewModel.perturbation?.run(fadeOut) }
        let showPerturbation = SKAction.run { [weak self] in self?.viewModel.perturbation?.run(fadeIn) }

        // Crear una acción de espera
        let wait = SKAction.wait(forDuration: 1.0) // Esperar 1 segundo

        // Crear una acción para reproducir el sonido
        let playSound = SKAction.run { [weak self] in
            self?.audioPlayer?.volume = 0.04
            self?.audioPlayer?.play()
        }

        // Crear una secuencia de acciones: animación, mostrar textura final, ocultar perturbación, esperar, mostrar perturbación
        let idleSequence = SKAction.sequence([hidePerturbation, radarAnimation, playSound, texturesModel.finalTexture, wait])

        // Crear una acción que repita la secuencia indefinidamente
        let repeatAnimation = SKAction.repeatForever(idleSequence)

        // Aplicar la acción al sprite
        sprite.run(repeatAnimation)

        sprite.size = CGSize(width: 400, height: 400)
        sprite.position = CGPoint(x: 0, y: 0)
        addChild(sprite)
        
        //Provisional Labels
        
        // Configura y añade decibelLevelLabel
        decibelLevelLabel.fontSize = 14
        decibelLevelLabel.fontColor = .white
        decibelLevelLabel.position = CGPoint(x: 0, y: 150) // Ajusta la posición según lo necesites
        decibelLevelLabel.horizontalAlignmentMode = .left
        addChild(decibelLevelLabel)

        // Configura y añade silenceDurationLabel
        silenceDurationLabel.fontSize = 14
        silenceDurationLabel.fontColor = .white
        silenceDurationLabel.position = CGPoint(x: 0, y: 130) // Ajusta la posición según lo necesites
        silenceDurationLabel.horizontalAlignmentMode = .left
        addChild(silenceDurationLabel)

        if let perturbation = SKEmitterNode(fileNamed: "Perturbation") {
            viewModel.perturbation = perturbation
            perturbation.position = CGPoint(x: 0, y: 100) // Inicia la perturbación en el borde del radar
            addChild(perturbation)
            perturbation.isHidden = true
            //compassHeading.perturbation = perturbation // Asignar la perturbación al manejador de la brújula
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
        
        // Actualizar las etiquetas con los valores actuales
        decibelLevelLabel.text = String(format: "Nivel de decibelios: %.2f", viewModel.averageLevel)
        silenceDurationLabel.text = "Duración del silencio: \(viewModel.silenceDuration)"
        }
        // Updating the Scene
    }

