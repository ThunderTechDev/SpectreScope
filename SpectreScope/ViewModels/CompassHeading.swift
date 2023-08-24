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
    
    init(viewModel: RadarViewModel, perturbation: Perturbation) {
        self.viewModel = viewModel
        self.perturbation = perturbation
        self.initialAngle = perturbation.angle
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
        
        let headingChange = newHeading.magneticHeading - initialHeading!
        
        if let initialAngle = self.initialAngle {
            let currentDistanceFromCenter: CGFloat = 190.0
            let adjustedAngle = initialAngle + headingChange * (.pi / 180.0)
            let x = currentDistanceFromCenter * cos(adjustedAngle)
            let y = currentDistanceFromCenter * sin(adjustedAngle)
            
            perturbation.entity?.position = CGPoint(x: x, y: y)
        }
    }
}
