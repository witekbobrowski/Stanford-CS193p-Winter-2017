//
//  GraphingView.swift
//  Calculator
//
//  Created by Witek on 27/04/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

// Programming Assingment 3 : Task 3
import UIKit

// Programming Assingment 3 : Task 10
@IBDesignable
class GraphingView: UIView {
    
    @IBInspectable
    var scale: CGFloat = 1 { didSet{ setNeedsDisplay() } }
    
    @IBInspectable
    var color: UIColor = .black { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var lineWidth: CGFloat = 4.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    private var origin: CGPoint! { didSet { setNeedsDisplay() } }
    
    private let axes = AxesDrawer(color: .black, contentScaleFactor: 1)
    
    // Programming Assingment 3 : Task6
    var data: GraphDataSource?
    
    // Programming Assingment 3 : Task 11
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    // Programming Assingment 3 : Task 11
    func changeOrigin(byReactingTo panRecogniser: UIPanGestureRecognizer) {
        switch panRecogniser.state {
        case .changed, .ended:
            origin.x += panRecogniser.translation(in: self).x
            origin.y += panRecogniser.translation(in: self).y
            panRecogniser.setTranslation(CGPoint(x: 0, y: 0), in: self)
        default:
            break
        }
    }
    
    // Programming Assingment 3 : Task 11
    func setOrigin(byReactingTo tapRecogniser: UITapGestureRecognizer) {
        switch tapRecogniser.state {
        case .ended:
            origin = tapRecogniser.location(in: self)
        default:
            break
        }
    }
    
    private func pathForFunction() -> UIBezierPath {
        let path = UIBezierPath()
        guard let source = data else { return path }
        let width = Int(bounds.size.width * scale)
        for pixel in 0...width{
            let x = CGFloat(pixel)/scale
            if let y = source.getY(x: (x - origin.x)/scale){
                if pixel == 0 {
                    path.move(to: CGPoint(x: x, y: origin.y - y * scale))
                } else if y.isNormal || y.isZero {
                    path.addLine(to: CGPoint(x: x, y: origin.y - y * scale))
                } else {
                    path.move(to: CGPoint(x: x, y: origin.y - y * scale))
                }
            }
        }
        path.lineWidth = lineWidth
        return path
    }
    
    override func draw(_ rect: CGRect) {
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        color.set()
        axes.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale)
        pathForFunction().stroke()
    }
}

protocol GraphDataSource {
    func getBounds() -> CGRect
    func getY (x: CGFloat) -> CGFloat?
}
