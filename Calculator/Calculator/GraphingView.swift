//
//  GraphingView.swift
//  Calculator
//
//  Created by Witek on 27/04/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import UIKit

@IBDesignable
class GraphingView: UIView {
    
    @IBInspectable
    var scale: CGFloat = 1 { didSet{ setNeedsDisplay() } }
    
    @IBInspectable
    var color: UIColor = .black { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    private var origin: CGPoint! { didSet { setNeedsDisplay() } }
    
    private let axes = AxesDrawer(color: .black, contentScaleFactor: 1)
    
    var data: GraphDataSource?
    
    override func draw(_ rect: CGRect) {
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        color.set()
        axes.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale)
        pathForFunction().stroke()
    }

    private func pathForFunction() -> UIBezierPath {
        var path = UIBezierPath()
        
        guard let source = data else {
            return path
        }
        
        // get the path here
        
        path.lineWidth = lineWidth
        return path
    }
}

protocol GraphDataSource {
    func getBounds() -> CGRect
    func getY (x: CGFloat) -> CGFloat?
}
