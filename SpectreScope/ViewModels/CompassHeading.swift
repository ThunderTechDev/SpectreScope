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
        heading = newHeading.magneticHeading

        if let initialAngle = viewModel.initialPerturbationAngle {
            let currentDistanceFromCenter: CGFloat = 190.0
            let adjustedAngle = (initialAngle + (heading * (.pi / 180.0))).truncatingRemainder(dividingBy: 2 * .pi)
            let x = currentDistanceFromCenter * cos(adjustedAngle)
            let y = currentDistanceFromCenter * sin(adjustedAngle)
            viewModel.perturbation?.position = CGPoint(x: x, y: y)
            print("El ángulo inicial es \(viewModel.initialPerturbationAngle!)")
            print("El valor del heading del magnetómetro es \(heading)")
            print("El valor del angulo ajustado es \(adjustedAngle)")
        }
    }
}
