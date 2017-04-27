//
//  GraphingViewController.swift
//  Calculator
//
//  Created by Witek on 26/04/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController, GraphDataSource {
    
    @IBOutlet weak var graphView: GraphingView!{
        didSet{
            graphView.data = self
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
}
