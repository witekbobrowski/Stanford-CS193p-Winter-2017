//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Witek on 20/03/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import Foundation

var sequence = [String: Double]()

struct CalculatorBrain {
    
    private var accumulator: (Double, String)?
    private var x: Double?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
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
    
    mutating func performOperation(_ symbol: String){
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = (value, symbol)
                sequence[symbol] = value
            case .unaryOperation(let function, let description):
                if accumulator != nil {
                    accumulator = (function(accumulator!.0), description(accumulator!.1))
                    sequence[symbol] = function(accumulator!.0)
                }
            case .binaryOperation(let function, let description):
                performPendingBinaryOperation()
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(description: description, function: function ,firstOperand: accumulator!)
                    sequence[symbol] = accumulator!.0
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
                sequence[symbol] = accumulator!.0
            }
        }
    }

    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String){
        // Programming Assingment 2 : Task 4
        if resultIsPending {
            
        }
        return (nil, false, "")
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
        sequence[String(operand)] = operand
        accumulator = (operand, "\(operand)")
    }
    
    mutating func setOperand(variable named: String){
        // Programming Assingment 2 : Task 3
        sequence[named] = sequence[named] ?? 0
        accumulator = (sequence[named]!, named)
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

