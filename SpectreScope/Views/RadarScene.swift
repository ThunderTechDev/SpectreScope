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
    let decibelLevelLabel = SKLabelNode(fontNamed: "Arial")
    let silenceDurationLabel = SKLabelNode(fontNamed: "Arial")
    var compassHeading: CompassHeading?
    var viewModel = RadarViewModel()
    var soundsModel = SoundsModel()
    var texturesModel = TexturesModel()
    var perturbation = Perturbation()
    var currentPerturbationAngle: CGFloat?
    var cancellables: Set<AnyCancellable> = []
    
    
    override func didMove(to view: SKView) {
        preloadTexturesAndSetupScene()
        observeViewModel()
        observeRadarDistanceViewModel()
        compassHeading = CompassHeading(viewModel: viewModel, perturbation: perturbation, scene: self)
    }
    
    
    func setupScene() {
        sprite.size = CGSize(width: 400, height: 400)
        sprite.position = CGPoint(x: 0, y: 0)
        addChild(sprite)
        setupAudioSession()
        soundsModel.setupSound()
        //setupLabels()
        showIdleAnimation()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        decibelLevelLabel.text = String(format: "Decibel Level: %.2f", viewModel.averageLevel)
        silenceDurationLabel.text = "Silence Duration: \(viewModel.silenceDuration)"
    }
    
    
    func setupLabels() {
        decibelLevelLabel.fontSize = 14
        decibelLevelLabel.fontColor = .white
        decibelLevelLabel.position = CGPoint(x: 0, y: 150)
        decibelLevelLabel.horizontalAlignmentMode = .left
        addChild(decibelLevelLabel)
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
        viewModel.averageLimit = -40
        let fadeOutPerturbation = SKAction.run { [weak self] in
            self?.perturbation.entity?.run(SKAction.fadeOut(withDuration: 0.2))
        }
        let playTapSound = SKAction.run { [weak self] in
            self?.soundsModel.tapAudioPlayer?.volume = 0.1
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
            let randomAngle = CGFloat.random(in: 0...2 * .pi)
               perturbation.angle = randomAngle
               compassHeading!.resetInitialAngle(to: randomAngle)
            let adjustedAngle = randomAngle + CGFloat(compassHeading!.lastHeadingChange) * (.pi / 180.0)
                currentPerturbationAngle = adjustedAngle
                updatePerturbationPosition()
        }
        let fadeInPerturbation = SKAction.run { [weak self] in
            self?.perturbation.entity?.run(SKAction.fadeIn(withDuration: 0.2))
        }
        let fadeOutPerturbation = SKAction.run { [weak self] in
            self?.perturbation.entity?.run(SKAction.fadeOut(withDuration: 0.2))
        }
        let playDistanceEffects = SKAction.run { [weak self] in
            self?.soundsModel.tapAudioPlayer?.volume = 0.1
            self?.soundsModel.tapAudioPlayer?.play()
            let radarDistance = self?.viewModel.perturbationRadarDistance ?? 190.0
            switch radarDistance {
            case 0:
                self?.showGhostFaceAndScream()
            case ..<45:
                self?.soundsModel.alarmAudioPlayer?.stop()
                self?.soundsModel.alarm2AudioPlayer?.stop()
                self?.soundsModel.alarm3AudioPlayer?.volume = 0.1
                self?.soundsModel.alarm3AudioPlayer?.play()
                self?.perturbation.setWhiteToRedGradient()
                self?.viewModel.averageLimit = -35
            case 45..<95:
                self?.soundsModel.alarmAudioPlayer?.stop()
                self?.soundsModel.alarm3AudioPlayer?.stop()
                self?.soundsModel.alarm2AudioPlayer?.volume = 0.1
                self?.soundsModel.alarm2AudioPlayer?.play()
                self?.perturbation.entity?.particleColorSequence = nil
                self?.perturbation.setWhiteToYellowGradient()
                let whispersVolume = 1 - (radarDistance / 95)
                self?.soundsModel.whispersAudioPlayer?.volume = Float(whispersVolume)
                self?.soundsModel.whispersAudioPlayer?.play()
            default:
                self?.soundsModel.alarm2AudioPlayer?.stop()
                self?.soundsModel.alarm3AudioPlayer?.stop()
                self?.soundsModel.whispersAudioPlayer?.stop()
                self?.soundsModel.alarmAudioPlayer?.volume = 0.1
                self?.soundsModel.alarmAudioPlayer?.play()
                self?.perturbation.setWhiteToCyanGradient()
            }
        }
        let radarAnimation = SKAction.animate(with: texturesModel.radarTextures, timePerFrame: 0.02)
        let waitAction = SKAction.wait(forDuration: 1.0)
        let perturbationSequence = SKAction.sequence([
            fadeInPerturbation,
            radarAnimation,
            fadeOutPerturbation,
            playDistanceEffects,
            texturesModel.finalTexture,
            waitAction
        ])
        sprite.run(SKAction.repeatForever(perturbationSequence))
    }
    
    
    func showGhostFaceAndScream() {
        let phantomFaceSprite = SKSpriteNode(texture: texturesModel.phantomFaceTexture)
        phantomFaceSprite.position = CGPoint(x: 0, y: 0)
        phantomFaceSprite.zPosition = 10
        phantomFaceSprite.size = CGSize(width: 400, height: 400)
        self.addChild(phantomFaceSprite)
        soundsModel.phantomScreamAudioPlayer?.play()
        stopPerturbationFunctionality()
        let waitAction = SKAction.wait(forDuration: 0.5)
        let removeAction = SKAction.removeFromParent()
        let sequenceAction = SKAction.sequence([waitAction, removeAction])
        phantomFaceSprite.run(sequenceAction)
        showIdleAnimation()
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
    
    
    func preloadTexturesAndSetupScene() {
        SKTexture.preload(texturesModel.radarTextures + [texturesModel.finalTextureImage]) {
            self.setupScene()
        }
    }
    
    
    func stopPerturbationFunctionality() {
        viewModel.averageLimit = -130
        viewModel.silenceDuration = 0
        viewModel.isPerturbationPositionSet = false
    }
}
