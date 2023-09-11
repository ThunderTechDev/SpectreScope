//
//  RadarViewModel.swift
//  SpectreScope
//
//  Created by Sergio Gonzalez Cristobal on 3/8/23.
//

import SwiftUI
import AVFoundation


class RadarViewModel: ObservableObject {
    var engine = AVAudioEngine()
    var silenceDuration: TimeInterval = 0
    private var accumulatedLevels: [Float] = []
    private var processSoundLevelTimer: Timer?
    @Published var perturbationAlreadyShowed = false
    @Published var averageLevel: Float
    @Published var averageLimit: Float = -30.0
    @Published var shouldShowPerturbation: Bool = false
    @Published var initialPerturbationAngle: CGFloat?
    @Published var isPerturbationPositionSet: Bool = false
    @Published var perturbationRadarDistance: CGFloat = 190.0

    init() {
        averageLevel = 0.0
        startMonitoringSoundLevel()
    }
    
    func startMonitoringSoundLevel() {
        let inputNode = engine.inputNode
        let outputFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: outputFormat) { [weak self] (buffer, time) in
            guard let self = self else { return }
            let level = self.calculateLevel(in: buffer)
            self.accumulatedLevels.append(level)
        }
        
        processSoundLevelTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(processAverageSoundLevel), userInfo: nil, repeats: true)
    }
    
    @objc private func processAverageSoundLevel() {
        averageLevel = accumulatedLevels.reduce(0, +) / Float(accumulatedLevels.count)
        accumulatedLevels.removeAll()
        
        if averageLevel < averageLimit {
            silenceDuration += 1
        } else {
            silenceDuration = 0
            isPerturbationPositionSet = false
        }
        
        if silenceDuration >= 15 {
            shouldShowPerturbation = true
            perturbationAlreadyShowed = true
            perturbationRadarDistance = max(perturbationRadarDistance - 5, 0)
            print("Distancia de la perturbacion \(perturbationRadarDistance)")
        } else {
            shouldShowPerturbation = false
        }
        
        try? engine.start()
    }
    
    func calculateLevel(in buffer: AVAudioPCMBuffer) -> Float {
        let channelDataValue = buffer.floatChannelData!.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map{ channelDataValue[$0] }
        let rms = sqrt(channelDataValueArray.map{ $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)
        
        return avgPower
    }
}
