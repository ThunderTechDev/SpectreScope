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
    
    let locationManager = CLLocationManager()
    
    init(viewModel: RadarViewModel) {
            self.viewModel = viewModel
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
        
        if let initialAngle = viewModel.initialPerturbationAngle {
            let currentDistanceFromCenter: CGFloat = 190.0
            let adjustedAngle = initialAngle + headingChange * (.pi / 180.0)
            let x = currentDistanceFromCenter * cos(adjustedAngle)
            let y = currentDistanceFromCenter * sin(adjustedAngle)
            
            viewModel.perturbation?.position = CGPoint(x: x, y: y)
        }
    }
}
