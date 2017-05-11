//
//  ViewController.swift
//  Calculator
//
//  Created by Witek on 15/03/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var variableDisplay: UILabel!
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    var userIsInTheMiddleOfTyping = false

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping{
            let textCurrentlyInDisplay = display.text!
            if digit == "." && textCurrentlyInDisplay.characters.contains("."){
                display.text = textCurrentlyInDisplay
            } else {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            if digit == "." {
                display.text = "0."
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            if newValue.truncatingRemainder(dividingBy: 1) == 0 {
                let formattedValue = String(newValue).characters.dropLast(2)
                display.text = String(formattedValue)
            } else {
                display.text = brain.formatter.string(from: NSNumber(value: newValue))
            }
        }
    }
    
    var displayVariable: Double{
        get {
            if variableDictionary.count != 0 {
                return (variableDictionary["M"])!
            } else {
                return 0
            }
        }
        set{
            if variableDictionary.count != 0 {
                variableDisplay.text = "M = \(newValue)"
            } else {
                variableDisplay.text = " "
            }
        }
    }
    
    var evaluatedResult: (result: Double?, isPending: Bool, description: String)? = nil{
        didSet {
            if let result = evaluatedResult!.result{
                displayValue = result
            }
            descriptionDisplay.text = (evaluatedResult!.isPending ? "\(evaluatedResult!.description) ..." : "\(evaluatedResult!.description) = ")
        }
    }
    
    private var brain = CalculatorBrain()
    private var variableDictionary = [String: Double]()
    
    @IBAction func clear(_ sender: UIButton) {
        display.text = "0"
        descriptionDisplay.text = " "
        variableDisplay.text = " "
        userIsInTheMiddleOfTyping = false
        variableDictionary = [:]
        brain = CalculatorBrain()
    }
    
    @IBAction func setVariable(_ sender: UIButton) {
        // Programming Assingment 2 : Task 7
        let symbol = String(sender.currentTitle!.characters.dropFirst())
        variableDictionary[symbol] = displayValue
        displayVariable = displayValue
        evaluatedResult = brain.evaluate(using: variableDictionary)
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func enterVariable(_ sender: UIButton) {
        // Programming Assingment 2 : Task 7
        brain.setOperand(variable: sender.currentTitle!)
        evaluatedResult = brain.evaluate()
    }
    
    @IBAction func undo(_ sender: UIButton) {
        // Programming Assingment 2 : Task 10
        brain.undo()
        evaluatedResult = brain.evaluate(using: variableDictionary)
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.evaluate(using: variableDictionary).result {
            displayValue = result
        }
        descriptionDisplay.text = brain.evaluate(using: variableDictionary).description + (brain.evaluate(using: variableDictionary).isPending ? "..." : " = ")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // Programming Assingment 3 : Task7
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationViewController = segue.destination
        
        if let navigationController = destinationViewController as? UINavigationController {
            destinationViewController = navigationController.visibleViewController ?? destinationViewController
        }
        if let graphingViewController = destinationViewController as? GraphingViewController {
            // Programming Assingment 3 : Task 9
            graphingViewController.navigationItem.title = self.brain.evaluate(using: self.variableDictionary).description
            graphingViewController.function = {(x: CGFloat) -> Double? in
                self.variableDictionary["M"] = Double(x)
                return self.brain.evaluate(using: self.variableDictionary).result
            }
        }
    }
    
//    Lecture 6 demo code
//      
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        brain.addUnaryOperation(named: "✅") { [unowned self] in
//            self.display.textColor = UIColor.green
//            return sqrt($0)
//        }
//    }
// 
    
}
