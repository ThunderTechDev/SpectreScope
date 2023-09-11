//
//  SoundsModel.swift
//  SpectreScope
//
//  Created by Sergio Gonzalez Cristobal on 7/9/23.
//

import AVFoundation

class SoundsModel {
    
    var tapAudioPlayer: AVAudioPlayer?
    var alarmAudioPlayer: AVAudioPlayer?
    var alarm2AudioPlayer: AVAudioPlayer?
    var alarm3AudioPlayer: AVAudioPlayer?
    var whispersAudioPlayer: AVAudioPlayer?
    var phantomScreamAudioPlayer: AVAudioPlayer?
    
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
        
        if let whispersURL = Bundle.main.url(forResource: "Whispers", withExtension: "wav") {
            do {
                whispersAudioPlayer = try AVAudioPlayer(contentsOf: whispersURL)
                whispersAudioPlayer?.numberOfLoops = -1
            } catch {
                print("No se pudo cargar el archivo de sonido Whispers.wav.")
            }
        }
        
        
        if let phantomScreamURL = Bundle.main.url(forResource: "PhantomScream", withExtension: "wav") {
            do {
                phantomScreamAudioPlayer = try AVAudioPlayer(contentsOf: phantomScreamURL)
            } catch {
                print("No se pudo cargar el archivo de sonido PhantomScream.wav.")
            }
        }
        
        
        
    }
    
    
    
}
