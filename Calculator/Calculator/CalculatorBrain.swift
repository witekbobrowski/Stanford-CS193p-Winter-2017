//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Witek on 20/03/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: (Double, String)?
    
    private enum Operation {
        case constant(Double, String)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    // Custom enum to help distinguish things that are being entered into the CalculatorBrain
    private enum Entries {
        case operand(Double)
        case operation(Operation)
        case variable(String)
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi, "π"),
        "e" : Operation.constant(M_E, "e"),
        "√" : Operation.unaryOperation(sqrt, {"√(\($0))"}),
        "cos" : Operation.unaryOperation(cos, {"cos(\($0))"}),
        "sin" : Operation.unaryOperation(sin, {"sin(\($0))"}),
        "tan" : Operation.unaryOperation(tan, {"tan(\($0))"}),
        "x²" : Operation.unaryOperation({ $0 * $0 }, {"(\($0))²"}),
        "±" : Operation.unaryOperation({ -$0 }, {"-(\($0))"}),
        "%" : Operation.unaryOperation({ $0 * 0.01 }, {"\($0) %"}),
        "×" : Operation.binaryOperation({ $0 * $1 }, {"\($0)  *  \($1)"}),
        "÷" : Operation.binaryOperation({ $0 / $1 }, {"\($0)  :  \($1)"}),
        "+" : Operation.binaryOperation({ $0 + $1 }, {"\($0)  +  \($1)"}),
        "−" : Operation.binaryOperation({ $0 - $1 }, {"\($0)  -  \($1)"}),
        "=" : Operation.equals
    ]
    
    private var sequence = [Entries]()
    
    mutating func performOperation(_ symbol: String){
        if let operation = operations[symbol] {
            sequence.append(Entries.operation(operation))
            switch operation {
            case .constant(let value, let description):
                accumulator = (value, description)
            case .unaryOperation(let function, let description):
                if accumulator != nil {
                    accumulator = (function(accumulator!.0), description(accumulator!.1))
                }
            case .binaryOperation(let function, let description):
                performPendingBinaryOperation()
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(description: description, function: function ,firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }

    // Programming Assingment 2 : Task 4
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String){
        
        // Under construction! Thanks Paul for making evaluate() NOT mutating... 
        
        var result: Double?
        var isPending: Bool = false
        var description: String = ""
        
        var tempSequence = sequence
        var tempDescription = ""
        
        func performOperation(_ operation: Operation){
            switch operation {
            case .constant(let value, let symbol):
                result = value
                tempDescription = symbol
            case .unaryOperation(let function, let text):
                if result != nil {
                    result = function(result!)
                }
                tempDescription = text(description)
            case .binaryOperation(let function, let text):
                if result != nil {
                    
                    isPending = true
                }
            case .equals:
                isPending = false
            }
        }

        for entry in tempSequence {
            switch entry{
            case .operand(let value):
                result = value
                tempDescription = String(value)
            case .operation(let operation):
                performOperation(operation)
            case .variable(let variable):
                tempDescription = variable
                if let dictionary = variables {
                    result = dictionary[variable]
                } else {
                    result = 0
                }
            }
            description += tempDescription
        }
    
        return (result, isPending, description)
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let description: (String, String) -> String
        let function: (Double, Double) -> Double
        let firstOperand: (Double, String)
        
        func perform(with secondOperand: (Double, String)) -> (Double, String) {
            return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
        }
    }
    
    mutating func setOperand(_ operand: Double){
        sequence.append(Entries.operand(operand))
        accumulator = (operand, "\(operand)")
    }
    
    mutating func setOperand(variable named: String){
        // Programming Assingment 2 : Task 3
        sequence.append(Entries.variable(named))
        accumulator = (0, named)
    }
    
    var result: Double? {
        get {
            if accumulator != nil {
                return accumulator!.0
            } else {
                return nil
            }
        }
    }
    
    var resultIsPending: Bool {
        get {
            if pendingBinaryOperation != nil {
                return true
            } else {
                return false
            }
        }
    }
    
    
    var description: String? {
        get {
            if resultIsPending {
                return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? "")
            } else {
                return accumulator?.1
            }
        }
    }
    
    var formatter:NumberFormatter {
        get{
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 6
            formatter.numberStyle = .decimal
            return formatter
        }
    }
}

