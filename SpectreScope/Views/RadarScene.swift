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
    var alarm2AudioPlayer: AVAudioPlayer?
    var alarm3AudioPlayer: AVAudioPlayer?
    var texturesModel = TexturesModel()
    var perturbation = Perturbation()
    let decibelLevelLabel = SKLabelNode(fontNamed: "Arial")
    let silenceDurationLabel = SKLabelNode(fontNamed: "Arial")
    var currentPerturbationAngle: CGFloat?
    
    var cancellables: Set<AnyCancellable> = []
    
    override func didMove(to view: SKView) {
        preloadTexturesAndSetupScene()
        observeViewModel()
        observeRadarDistanceViewModel()
        compassHeading = CompassHeading(viewModel: viewModel, perturbation: perturbation, scene: self)
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
                alarmAudioPlayer?.enableRate = true
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
        
        if let alarm2URL = Bundle.main.url(forResource: "Alarm2", withExtension: "wav") {
               do {
                   alarm2AudioPlayer = try AVAudioPlayer(contentsOf: alarm2URL)
               } catch {
                   print("No se pudo cargar el archivo de sonido Alarm2.wav.")
               }
           }

           if let alarm3URL = Bundle.main.url(forResource: "Alarm3", withExtension: "wav") {
               do {
                   alarm3AudioPlayer = try AVAudioPlayer(contentsOf: alarm3URL)
               } catch {
                   print("No se pudo cargar el archivo de sonido Alarm3.wav.")
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
        sprite.removeAllActions()
        
        
        if !viewModel.isPerturbationPositionSet && viewModel.perturbationAlreadyShowed == false {
            viewModel.isPerturbationPositionSet = true
            addChild(perturbation.entity!)
            perturbation.entity?.isHidden = false
        } else if !viewModel.isPerturbationPositionSet && viewModel.perturbationAlreadyShowed == true {
            viewModel.isPerturbationPositionSet = true
            viewModel.perturbationRadarDistance = 190.0
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

            let radarDistance = self?.viewModel.perturbationRadarDistance ?? 190.0
            if radarDistance <= 45 {
                self?.alarmAudioPlayer?.stop()
                self?.alarm2AudioPlayer?.stop()
                self?.alarm3AudioPlayer?.volume = 0.5
                self?.alarm3AudioPlayer?.play()
            } else if radarDistance <= 95 {
                self?.alarmAudioPlayer?.stop()
                self?.alarm3AudioPlayer?.stop()
                self?.alarm2AudioPlayer?.volume = 0.5
                self?.alarm2AudioPlayer?.play()
            } else {
                self?.alarm2AudioPlayer?.stop()
                self?.alarm3AudioPlayer?.stop()
                self?.alarmAudioPlayer?.volume = 0.5
                self?.alarmAudioPlayer?.play()
            }
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
    
    func updatePerturbationPosition() {
        let x = cos(currentPerturbationAngle ?? 0) * viewModel.perturbationRadarDistance
        let y = sin(currentPerturbationAngle ?? 0) * viewModel.perturbationRadarDistance
        perturbation.entity?.position = CGPoint(x: x, y: y)
    }
    

    func observeRadarDistanceViewModel() {
        viewModel.$perturbationRadarDistance.sink { [weak self] _ in
            self?.updatePerturbationPosition()
        }.store(in: &cancellables)
    }
    
   
    
    override func update(_ currentTime: TimeInterval) {
        decibelLevelLabel.text = String(format: "Decibel Level: %.2f", viewModel.averageLevel)
        silenceDurationLabel.text = "Silence Duration: \(viewModel.silenceDuration)"
    }
}
