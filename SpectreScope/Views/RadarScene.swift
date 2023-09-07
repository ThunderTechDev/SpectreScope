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
    var soundsModel = SoundsModel()
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
        setupAudioSession()
        soundsModel.setupSound()
        setupLabels()
        
        setupIdleAnimation()
    }
    
    func setupIdleAnimation() {
        let radarAnimation = SKAction.animate(with: texturesModel.radarTextures, timePerFrame: 0.02)
        
        let idleSequence = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.soundsModel.alarmAudioPlayer?.stop()
                self?.soundsModel.tapAudioPlayer?.volume = 1.0
                self?.soundsModel.tapAudioPlayer?.play()
            },
            radarAnimation,
            texturesModel.finalTexture,
            SKAction.wait(forDuration: 1.0)
        ])
        
        sprite.run(SKAction.repeatForever(idleSequence))
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
            self?.soundsModel.tapAudioPlayer?.volume = 1.0
            self?.soundsModel.tapAudioPlayer?.play()
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
        
        soundsModel.whispersAudioPlayer?.stop()
        soundsModel.whispersAudioPlayer?.volume = 0

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
        
     
            let randomAngle = CGFloat.random(in: 0...2 * .pi) // Ángulo aleatorio entre 0 y 360 grados
               perturbation.angle = randomAngle
               compassHeading!.resetInitialAngle(to: randomAngle)
            
            let adjustedAngle = randomAngle + CGFloat(compassHeading!.lastHeadingChange) * (.pi / 180.0)
                currentPerturbationAngle = adjustedAngle
                updatePerturbationPosition()
            
        }
        
        
        // 3. Define las acciones individuales.
        let fadeInPerturbation = SKAction.run { [weak self] in
            self?.perturbation.entity?.run(SKAction.fadeIn(withDuration: 0.2))
        }
        
        let fadeOutPerturbation = SKAction.run { [weak self] in
            self?.perturbation.entity?.run(SKAction.fadeOut(withDuration: 0.2))
        }
        
        let playSoundEffects = SKAction.run { [weak self] in
            self?.soundsModel.tapAudioPlayer?.volume = 1.0
            self?.soundsModel.tapAudioPlayer?.play()

            let radarDistance = self?.viewModel.perturbationRadarDistance ?? 190.0
            if radarDistance <= 45 {
                self?.soundsModel.alarmAudioPlayer?.stop()
                self?.soundsModel.alarm2AudioPlayer?.stop()
                self?.soundsModel.alarm3AudioPlayer?.volume = 0.5
                self?.soundsModel.alarm3AudioPlayer?.play()
                self?.perturbation.setWhiteToRedGradient()
            } else if radarDistance <= 95 {
                self?.soundsModel.alarmAudioPlayer?.stop()
                self?.soundsModel.alarm3AudioPlayer?.stop()
                self?.soundsModel.alarm2AudioPlayer?.volume = 0.5
                self?.soundsModel.alarm2AudioPlayer?.play()
                self?.perturbation.entity?.particleColorSequence = nil
                self?.perturbation.setWhiteToYellowGradient()
                
                // Calculate and set volume for whispers based on radarDistance
                let whispersVolume = 1.5 - (radarDistance / 95)
                print(whispersVolume)
                self?.soundsModel.whispersAudioPlayer?.volume = Float(whispersVolume)
                self?.soundsModel.whispersAudioPlayer?.play()
            } else {
                self?.soundsModel.alarm2AudioPlayer?.stop()
                self?.soundsModel.alarm3AudioPlayer?.stop()
                self?.soundsModel.whispersAudioPlayer?.stop() // Ensure that whispers stop if perturbation moves further away
                self?.soundsModel.alarmAudioPlayer?.volume = 0.5
                self?.soundsModel.alarmAudioPlayer?.play()
                self?.perturbation.setWhiteToCyanGradient()
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
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error al configurar AVAudioSession:", error)
        }
    }
    
   
    
    override func update(_ currentTime: TimeInterval) {
        decibelLevelLabel.text = String(format: "Decibel Level: %.2f", viewModel.averageLevel)
        silenceDurationLabel.text = "Silence Duration: \(viewModel.silenceDuration)"
    }
}
