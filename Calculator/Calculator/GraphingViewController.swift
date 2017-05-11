//
//  GraphingViewController.swift
//  Calculator
//
//  Created by Witek on 26/04/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController, GraphDataSource {
    
    // Programming Assingment 3 : Task 11
    @IBOutlet weak var graphView: GraphingView!{
        didSet{
            graphView.data = self
            // Programming Assingment 3 : Task 11 a. Pinching
            let pinchHandler = #selector(GraphingView.changeScale(byReactingTo:))
            let pinchRecogniser = UIPinchGestureRecognizer(target: graphView, action: pinchHandler)
            graphView.addGestureRecognizer(pinchRecogniser)
            // Programming Assingment 3 : Task 11 b. Panning
            let panHandler = #selector(GraphingView.changeOrigin(byReactingTo:))
            let panRecogniser = UIPanGestureRecognizer(target: graphView, action: panHandler)
            graphView.addGestureRecognizer(panRecogniser)
            // Programming Assingment 3 : Task 11 c. Double-tapping
            let tapHandler = #selector(GraphingView.setOrigin(byReactingTo:))
            let tapRecogniser = UITapGestureRecognizer(target: graphView, action: tapHandler)
            tapRecogniser.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapRecogniser)
        }
    }
    
    var function: ((CGFloat) -> Double?)?
    
    func getY (x: CGFloat) -> CGFloat? {
        if let function = function, let result = function(x){
            return CGFloat(result)
        } else {
            return nil
        }
    }
    
    func getBounds() -> CGRect {
        return view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}
