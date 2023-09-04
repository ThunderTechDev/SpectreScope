//
//  CompassHeading.swift
//  SpectreScope
//
//  Created by Sergio Gonzalez Cristobal on 3/8/23.
//

import SwiftUI
import CoreLocation


class CompassHeading: NSObject, CLLocationManagerDelegate {
    
    var heading: Double = 0.0
    var viewModel: RadarViewModel
    var initialHeading: CLLocationDirection?
    var perturbation: Perturbation
    let locationManager = CLLocationManager()
    var initialAngle: CGFloat?
    weak var scene: RadarScene?
    
    var lastHeadingChange: CLLocationDirection = 0.0
    
    
    init(viewModel: RadarViewModel, perturbation: Perturbation, scene: RadarScene) {
        self.viewModel = viewModel
        self.perturbation = perturbation
        self.initialAngle = perturbation.angle
        self.scene = scene
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
        if initialHeading == nil {
            initialHeading = newHeading.magneticHeading
        }
        
        lastHeadingChange = newHeading.magneticHeading - initialHeading!
        
        if let initialAngle = self.initialAngle {
            let adjustedAngle = initialAngle + lastHeadingChange * (.pi / 180.0)
            scene?.currentPerturbationAngle = adjustedAngle
            scene?.updatePerturbationPosition()
        }
    }
    
    func resetInitialAngle(to newAngle: CGFloat) {
        self.initialAngle = newAngle
    }
    
    
}


