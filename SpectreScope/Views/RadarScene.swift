//
//  RadarScene.swift
//  SpectreScope
//
//  Created by Sergio Gonzalez Cristobal on 20/7/23.
//

import SwiftUI
import SpriteKit
import AVFoundation
import Combine

class RadarScene: SKScene {
    let sprite = SKSpriteNode()
    var compassHeading: CompassHeading?
    var viewModel = RadarViewModel()
    var audioPlayer: AVAudioPlayer?
    var texturesModel = TexturesModel()
    
    let decibelLevelLabel = SKLabelNode(fontNamed: "Arial")
    let silenceDurationLabel = SKLabelNode(fontNamed: "Arial")
    
    var cancellables: Set<AnyCancellable> = []

    override func didMove(to view: SKView) {
        setupScene()
        observeViewModel()
    }

    func setupScene() {
        compassHeading = CompassHeading(viewModel: viewModel)
        
        // Crear acciones para hacer desaparecer y aparecer la perturbación
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let hidePerturbation = SKAction.run { [weak self] in self?.viewModel.perturbation?.run(fadeOut) }
        let showPerturbation = SKAction.run { [weak self] in self?.viewModel.perturbation?.run(fadeIn) }

        // Crear una acción para reproducir el sonido
        let playSound = SKAction.run { [weak self] in
            self?.audioPlayer?.volume = 0.04
            self?.audioPlayer?.play()
        }

        // Crear una secuencia de acciones: animación, mostrar textura final, ocultar perturbación, esperar, mostrar perturbación
        let radarAnimation = SKAction.animate(with: texturesModel.radarTextures, timePerFrame: 0.02)
        let wait = SKAction.wait(forDuration: 1.0) // Esperar 1 segundo

        let idleSequence = SKAction.sequence([hidePerturbation, radarAnimation, playSound, texturesModel.finalTexture, wait])
        let perturbationSequence = SKAction.sequence([showPerturbation, radarAnimation, hidePerturbation, playSound, texturesModel.finalTexture, wait])
        
        sprite.run(SKAction.repeatForever(idleSequence))

        sprite.size = CGSize(width: 400, height: 400)
        sprite.position = CGPoint(x: 0, y: 0)
        addChild(sprite)
        
        // Configura y añade decibelLevelLabel
        decibelLevelLabel.fontSize = 14
        decibelLevelLabel.fontColor = .white
        decibelLevelLabel.position = CGPoint(x: 0, y: 150)
        decibelLevelLabel.horizontalAlignmentMode = .left
        addChild(decibelLevelLabel)

        // Configura y añade silenceDurationLabel
        silenceDurationLabel.fontSize = 14
        silenceDurationLabel.fontColor = .white
        silenceDurationLabel.position = CGPoint(x: 0, y: 130)
        silenceDurationLabel.horizontalAlignmentMode = .left
        addChild(silenceDurationLabel)
        
        if let perturbation = SKEmitterNode(fileNamed: "Perturbation") {
            viewModel.perturbation = perturbation
            perturbation.position = CGPoint(x: 0, y: 100)
            addChild(perturbation)
            perturbation.isHidden = true
        }

        if let url = Bundle.main.url(forResource: "Tap", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            } catch {
                print("No se pudo cargar el archivo de sonido.")
            }
        }
    }

    func observeViewModel() {
        viewModel.$shouldShowPerturbation.sink { [weak self] shouldShow in
            if shouldShow {
                self?.showPerturbationAnimation()
            } else {
                self?.showIdleAnimation()
            }
        }.store(in: &cancellables)
    }

    func showIdleAnimation() {
        sprite.removeAllActions()
        let idleSequence = SKAction.sequence([
            SKAction.run { [weak self] in self?.viewModel.perturbation?.run(SKAction.fadeOut(withDuration: 0.2)) },
            SKAction.animate(with: texturesModel.radarTextures, timePerFrame: 0.02),
            SKAction.run { [weak self] in
                self?.audioPlayer?.volume = 0.04
                self?.audioPlayer?.play()
            },
            texturesModel.finalTexture,
            SKAction.wait(forDuration: 1.0)
        ])
        sprite.run(SKAction.repeatForever(idleSequence))
    }

    func showPerturbationAnimation() {
        sprite.removeAllActions()
        
        let angle = CGFloat.random(in: 0..<(2 * .pi))
        let x = 200 + cos(angle) * 200
        let y = 200 + sin(angle) * 200
        viewModel.perturbation?.position = CGPoint(x: x, y: y)
        viewModel.perturbation?.isHidden = false
        
        let perturbationSequence = SKAction.sequence([
            SKAction.run { [weak self] in self?.viewModel.perturbation?.run(SKAction.fadeIn(withDuration: 0.2)) },
            SKAction.animate(with: texturesModel.radarTextures, timePerFrame: 0.02),
            SKAction.run { [weak self] in self?.viewModel.perturbation?.run(SKAction.fadeOut(withDuration: 0.2)) },
            SKAction.run { [weak self] in
                self?.audioPlayer?.volume = 0.04
                self?.audioPlayer?.play()
            },
            texturesModel.finalTexture,
            SKAction.wait(forDuration: 1.0)
        ])
        sprite.run(SKAction.repeatForever(perturbationSequence))
    }

    override func update(_ currentTime: TimeInterval) {
        decibelLevelLabel.text = String(format: "Nivel de decibelios: %.2f", viewModel.averageLevel)
        silenceDurationLabel.text = "Duración del silencio: \(viewModel.silenceDuration)"
    }
}
