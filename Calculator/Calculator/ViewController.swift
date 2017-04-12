//
//  ViewController.swift
//  Calculator
//
//  Created by Witek on 15/03/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
    
    private var brain = CalculatorBrain()
    
    @IBAction func clear(_ sender: UIButton) {
        display.text = "0"
        descriptionDisplay.text = " "
        variableDisplay.text = " "
        userIsInTheMiddleOfTyping = false
        brain = CalculatorBrain()
    }
    
    @IBAction func setVariable(_ sender: UIButton) {
        // Programming Assingment 2 : Task 7
        //if sequence.count > 1 { sequence.removeAll() }
        sequence["M"] = displayValue
        variableDisplay.text = "M = \(displayValue)"
        let evaluationResult = brain.evaluate(using: sequence)
        if evaluationResult.isPending {
            displayValue = evaluationResult.result!
            descriptionDisplay.text = evaluationResult.description
        }
    }
    
    @IBAction func enterVariable(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        // Programming Assingment 2 : Task 7
    }
    
    @IBAction func undo(_ sender: UIButton) {
        // Programming Assingment 2 : Task 10
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        if let description = brain.description {
            descriptionDisplay.text = description + (brain.resultIsPending ? "..." : " = ")
        }
    }
    
}
