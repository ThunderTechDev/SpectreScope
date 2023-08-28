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
    var tapAudioPlayer: AVAudioPlayer?
    var alarmAudioPlayer: AVAudioPlayer?
    var texturesModel = TexturesModel()
    var perturbation = Perturbation()
    let decibelLevelLabel = SKLabelNode(fontNamed: "Arial")
    let silenceDurationLabel = SKLabelNode(fontNamed: "Arial")
    
    var cancellables: Set<AnyCancellable> = []
    
    override func didMove(to view: SKView) {
        preloadTexturesAndSetupScene()
        observeViewModel()
        compassHeading = CompassHeading(viewModel: viewModel, perturbation: perturbation)
        //print("Ángulo inicial de la perturbación \(perturbation.angle)")
    }
    
    func preloadTexturesAndSetupScene() {
        SKTexture.preload(texturesModel.radarTextures + [texturesModel.finalTextureImage]) {
            self.setupScene()
        }
    }
    
    func setupScene() {
        sprite.size = CGSize(width: 400, height: 400)
        sprite.position = CGPoint(x: 0, y: 0)
        addChild(sprite)

        setupSound()
        setupLabels()
        
        setupIdleAnimation()
    }
    
    func setupIdleAnimation() {
        let radarAnimation = SKAction.animate(with: texturesModel.radarTextures, timePerFrame: 0.02)
        
        let idleSequence = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.alarmAudioPlayer?.stop()
                self?.tapAudioPlayer?.volume = 1.0
                self?.tapAudioPlayer?.play()
            },
            radarAnimation,
            texturesModel.finalTexture,
            SKAction.wait(forDuration: 1.0)
        ])
        
        sprite.run(SKAction.repeatForever(idleSequence))
    }
    
    func setupSound() {
        if let tapURL = Bundle.main.url(forResource: "Tap", withExtension: "wav") {
            do {
                tapAudioPlayer = try AVAudioPlayer(contentsOf: tapURL)
            } catch {
                print("No se pudo cargar el archivo de sonido tap.wav.")
            }
        }

        if let alarmURL = Bundle.main.url(forResource: "Alarm", withExtension: "wav") {
            do {
                alarmAudioPlayer = try AVAudioPlayer(contentsOf: alarmURL)
            } catch {
                print("No se pudo cargar el archivo de sonido alarm.wav.")
            }
        }
    }
    
    func setupLabels() {
        // Label Noise Control
        decibelLevelLabel.fontSize = 14
        decibelLevelLabel.fontColor = .white
        decibelLevelLabel.position = CGPoint(x: 0, y: 150)
        decibelLevelLabel.horizontalAlignmentMode = .left
        addChild(decibelLevelLabel)
        
        // Label Silence Duration
        silenceDurationLabel.fontSize = 14
        silenceDurationLabel.fontColor = .white
        silenceDurationLabel.position = CGPoint(x: 0, y: 130)
        silenceDurationLabel.horizontalAlignmentMode = .left
        addChild(silenceDurationLabel)
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
        
        let fadeOutPerturbation = SKAction.run { [weak self] in
            self?.perturbation.entity?.run(SKAction.fadeOut(withDuration: 0.2))
        }

        let playTapSound = SKAction.run { [weak self] in
            self?.tapAudioPlayer?.volume = 1.0
            self?.tapAudioPlayer?.play()
        }

        let radarAnimation = SKAction.animate(with: texturesModel.radarTextures, timePerFrame: 0.02)
        let waitAction = SKAction.wait(forDuration: 1.0)
        
        let idleSequence = SKAction.sequence([
            fadeOutPerturbation,
            radarAnimation,
            playTapSound,
            texturesModel.finalTexture,
            waitAction
        ])

        sprite.run(SKAction.repeatForever(idleSequence))
    }
    
    func showPerturbationAnimation() {
        // 1. Limpia las acciones anteriores.
        sprite.removeAllActions()
        
        // 2. Configura la perturbación si es necesario.
        if !viewModel.isPerturbationPositionSet {
            viewModel.isPerturbationPositionSet = true
            addChild(perturbation.entity!)
            perturbation.entity?.position = perturbation.position
            perturbation.entity?.isHidden = false
            
            
        }
        
        // 3. Define las acciones individuales.
        let fadeInPerturbation = SKAction.run { [weak self] in
            self?.perturbation.entity?.run(SKAction.fadeIn(withDuration: 0.2))
        }
        
        let fadeOutPerturbation = SKAction.run { [weak self] in
            self?.perturbation.entity?.run(SKAction.fadeOut(withDuration: 0.2))
        }
        
        let playSoundEffects = SKAction.run { [weak self] in
            self?.tapAudioPlayer?.volume = 1.0
            self?.tapAudioPlayer?.play()
            self?.alarmAudioPlayer?.volume = 0.5
            self?.alarmAudioPlayer?.play()
        }
        
        let radarAnimation = SKAction.animate(with: texturesModel.radarTextures, timePerFrame: 0.02)
        
        let waitAction = SKAction.wait(forDuration: 1.0)

        // 4. Combinar las acciones en una secuencia.
        let perturbationSequence = SKAction.sequence([
            fadeInPerturbation,
            radarAnimation,
            fadeOutPerturbation,
            playSoundEffects,
            texturesModel.finalTexture,
            waitAction
        ])

        // 5. Ejecuta la secuencia repetidamente.
        sprite.run(SKAction.repeatForever(perturbationSequence))
    }
    
    override func update(_ currentTime: TimeInterval) {
        decibelLevelLabel.text = String(format: "Decibel Level: %.2f", viewModel.averageLevel)
        silenceDurationLabel.text = "Silence Duration: \(viewModel.silenceDuration)"
    }
}
