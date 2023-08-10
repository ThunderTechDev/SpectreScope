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
    
    let decibelLevelLabel = SKLabelNode(fontNamed: "Arial")
    let silenceDurationLabel = SKLabelNode(fontNamed: "Arial")
    
    var cancellables: Set<AnyCancellable> = []
    
    override func didMove(to view: SKView) {
        setupScene()
        observeViewModel()
    }
    
    func setupScene() {
        
        compassHeading = CompassHeading(viewModel: viewModel)
        
        sprite.size = CGSize(width: 400, height: 400)
        sprite.position = CGPoint(x: 0, y: 0)
        addChild(sprite)
        
        let radarAnimation = SKAction.animate(with: texturesModel.radarTextures, timePerFrame: 0.02)
        
        let idleSequence = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.alarmAudioPlayer?.stop()
                self?.tapAudioPlayer?.volume = 0.04
                self?.tapAudioPlayer?.play()
            },
            radarAnimation,
            texturesModel.finalTexture,
            SKAction.wait(forDuration: 1.0)
        ])
        
        
        sprite.run(SKAction.repeatForever(idleSequence))
        

        
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
                self?.tapAudioPlayer?.volume = 0.04
                self?.tapAudioPlayer?.play()
            },
            texturesModel.finalTexture,
            SKAction.wait(forDuration: 1.0)
        ])
        sprite.run(SKAction.repeatForever(idleSequence))
    }
    
    func showPerturbationAnimation() {
        sprite.removeAllActions()
        
        if !viewModel.isPerturbationPositionSet {
            let angle = CGFloat.random(in: 0..<(2 * .pi))
            let x = 0 + cos(angle) * 190
            let y = 0 + sin(angle) * 190
            print("La perturbación está en la posición: x - \(x); y - \(y)")
            viewModel.perturbation?.position = CGPoint(x: x, y: y)
            viewModel.isPerturbationPositionSet = true
        }
        viewModel.perturbation?.isHidden = false
        
        let perturbationSequence = SKAction.sequence([
            SKAction.run { [weak self] in self?.viewModel.perturbation?.run(SKAction.fadeIn(withDuration: 0.2)) },
            SKAction.animate(with: texturesModel.radarTextures, timePerFrame: 0.02),
            SKAction.run { [weak self] in self?.viewModel.perturbation?.run(SKAction.fadeOut(withDuration: 0.2)) },
            SKAction.run { [weak self] in
                self?.tapAudioPlayer?.volume = 0.04
                self?.tapAudioPlayer?.play()
                self?.alarmAudioPlayer?.volume = 0.03
                self?.alarmAudioPlayer?.play()
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
