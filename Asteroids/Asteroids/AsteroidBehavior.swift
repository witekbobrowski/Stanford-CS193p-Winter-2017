//
//  AsteroidBehavior.swift
//  Asteroids
//
//  Created by Witek on 18/09/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import UIKit

class AsteroidBehavior: UIDynamicBehavior {
    
    fileprivate var asteroids: [AsteroidView] = []
    fileprivate var collisionHandlers: [String:()->()] = [:]
    fileprivate lazy var collider: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.collisionMode = .boundaries
//        behavior.translatesReferenceBoundsIntoBoundary = true
        behavior.collisionDelegate = self
        return behavior
    }()
    fileprivate lazy var physics: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 1
        behavior.allowsRotation = true
        behavior.friction = 0
        behavior.resistance = 0
        return behavior
    }()
    lazy var acceleration: UIGravityBehavior = {
        let behavior = UIGravityBehavior()
        behavior.magnitude = 0
        return behavior
    }()
    var recaptureCount = 0
    private weak var recaptureTimer: Timer?
    var speedLimit: CGFloat = 300.0
    
    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(physics)
        addChildBehavior(acceleration)
        physics.action = { [weak self] in
            for asteroid in self?.asteroids ?? [] {
                let velocity = self!.physics.linearVelocity(for: asteroid)
                let excessHorizontalVelocity = min(self!.speedLimit - velocity.x, 0)
                let excessVerticalVelocity = min(self!.speedLimit - velocity.y, 0)
                self!.physics.addLinearVelocity(
                    CGPoint(x: excessHorizontalVelocity, y: excessVerticalVelocity),
                    for: asteroid
                )
            }
        }
        
    }
    
    func addAsteroid(_ asteroid: AsteroidView) {
        asteroids.append(asteroid)
        collider.addItem(asteroid)
        physics.addItem(asteroid)
        acceleration.addItem(asteroid)
        startRecapturingWaywardAsteroids()
    }
    
    func removeAsteroid(_ asteroid: AsteroidView) {
        if let index = asteroids.index(of: asteroid) {
            asteroids.remove(at: index)
        }
        collider.removeItem(asteroid)
        physics.removeItem(asteroid)
        acceleration.removeItem(asteroid)
        if asteroids.isEmpty {
            stopRecapturingWaywardAsteroids()
        }
    }
    
    func pushAllAsteroids(by magniture: Range<CGFloat> = 0..<0.5) {
        for asteroid in asteroids {
            let pusher = UIPushBehavior(items: [asteroid], mode: .instantaneous)
            pusher.magnitude = CGFloat.random(in: magniture)
            pusher.angle = CGFloat.random(in: 0..<CGFloat.pi*2)
            addChildBehavior(pusher)
        }
    }
    
    func setBoundary(_ path: UIBezierPath?, named name: String, handler: (() -> ())?) {
        collider.removeBoundary(withIdentifier: name as NSString)
        collisionHandlers[name] = nil
        if path != nil {
            collider.addBoundary(withIdentifier: name as NSString, for: path!)
            collisionHandlers[name] = handler
        }
    }
    
    private func startRecapturingWaywardAsteroids() {
        if recaptureTimer == nil {
            recaptureTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer     in for asteroid in self?.asteroids ?? [] {
                    if let asteroidFieldBounds = asteroid.superview?.bounds, !asteroidFieldBounds.contains(asteroid.center) { asteroid.center.x =   asteroid.center.x.truncatingRemainder(dividingBy: asteroidFieldBounds.width)
                        if asteroid.center.x < 0 { asteroid.center.x += asteroidFieldBounds.width }
                        asteroid.center.y = asteroid.center.y.truncatingRemainder(dividingBy: asteroidFieldBounds.height)
                        if asteroid.center.y < 0 { asteroid.center.y += asteroidFieldBounds.height }
                        self?.dynamicAnimator?.updateItem(usingCurrentState: asteroid)
                        self?.recaptureCount += 1
                    }
                }
            }
        }
    }
    
    private func stopRecapturingWaywardAsteroids() {
        recaptureTimer?.invalidate()
        
    }
    
    override func willMove(to dynamicAnimator: UIDynamicAnimator?) {
        super.willMove(to: dynamicAnimator)
        if dynamicAnimator == nil {
            stopRecapturingWaywardAsteroids()
        } else if !asteroids.isEmpty {
            startRecapturingWaywardAsteroids()
        }
    }
    
}

extension AsteroidBehavior: UICollisionBehaviorDelegate {
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        if let name = identifier as? String, let handler = collisionHandlers[name] {
            handler()
        }
    }
    
}
