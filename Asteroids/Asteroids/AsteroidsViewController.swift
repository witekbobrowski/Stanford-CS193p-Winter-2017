//
//  AsteroidsViewController.swift
//  Asteroids
//
//  Created by Witek on 18/09/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import UIKit

class AsteroidsViewController: UIViewController {
    
    // MARK: Constants
    
    private struct Constants {
        static let initialAsteroidCount = 20
        static let shipBoundaryName = "Ship"
        static let shipSizeToMinBoundsEdgeRatio: CGFloat = 1/5
        static let asteroidFieldMagnitude: CGFloat = 10 // as a multiple of view.bounds.size
        static let burnAcceleration: CGFloat = 0.07 // points/s/s
        
        struct Shield {
            static let duration: TimeInterval = 1.0 // how long shield stays up
            static let activationCost: Double = 15 // per activation
        }
    }

    private var asteroidField: AsteroidFieldView!
    private var shipView: SpaceshipView!
    private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.asteroidField)
    private var asteroidBehavior = AsteroidBehavior()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initializeIfNeeded()
        animator.addBehavior(asteroidBehavior)
        asteroidBehavior.pushAllAsteroids()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animator.removeBehavior(asteroidBehavior)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        asteroidField?.center = view.bounds.mid
        repositionShip()
    }
    
    @IBAction func burn(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            shipView.direction = (sender.location(in: view) - shipView.center).angle
            burn()
        case .ended:
            endBurn()
        default:
            break
        }
    }
    
    private func burn() {
        shipView.enginesAreFiring = true
        asteroidBehavior.acceleration.angle = shipView.direction - .pi
        asteroidBehavior.acceleration.magnitude = Constants.burnAcceleration
    }
    
    private func endBurn() {
        shipView.enginesAreFiring = false
        asteroidBehavior.acceleration.magnitude = 0
    }
    private func initializeIfNeeded() {
        if asteroidField == nil {
            asteroidField = AsteroidFieldView(frame: CGRect(center: view.bounds.mid, size: view.bounds.size * Constants.asteroidFieldMagnitude))
            view.addSubview(asteroidField)
            let shipSize = view.bounds.size.minEdge * Constants.shipSizeToMinBoundsEdgeRatio
            shipView = SpaceshipView(frame: CGRect(squareCenteredAt: asteroidField.center , size: shipSize))
            view.addSubview(shipView)
            repositionShip()
            asteroidField.asteroidBehavior = asteroidBehavior
            asteroidField.addAsteroids(count: Constants.initialAsteroidCount, exclusionZone: shipView.convert(shipView.bounds, to: asteroidField))
        }
    }
    
    private func repositionShip() {
        if asteroidField != nil {
            shipView.center = asteroidField.center
            asteroidBehavior.setBoundary(shipView.shieldBoundary(in: asteroidField) , named: Constants.shipBoundaryName) { [weak self] in
                if let ship = self?.shipView {
                    guard !ship.shieldIsActive else {
                        return
                    }
                    ship.shieldIsActive = true
                    ship.shieldLevel -= Constants.Shield.activationCost
                    Timer.scheduledTimer(withTimeInterval: Constants.Shield.duration, repeats: false) { timer in
                        ship.shieldIsActive = false
                        if ship.shieldLevel == 0 {
                            ship.shieldLevel = 100
                        }
                    }
                }
            }
        }
    }
}

