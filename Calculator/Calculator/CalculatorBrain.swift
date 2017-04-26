//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Witek on 20/03/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    /*
    mutating func addUnaryOperation(named symbol: String, _ operation: @escaping (Double) -> Double) {
        operations[symbol] = Operation.unaryOperation(operation, {"√(\($0))"})
    }
    */
    
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
        
        var result: (Double, String)?
        var pendingOperation: PendingBinaryOperation?
        var isPending: Bool {
            get{
                if pendingOperation != nil {
                    return true
                } else {
                    return false
                }
            }
        }
        
        func performOperation(_ operation: Operation){
            switch operation {
            case .constant(let value, let symbol):
                result = (value, symbol)
            case .unaryOperation(let function, let description):
                if result != nil {
                    result = (function(result!.0), description(result!.1))
                }
            case .binaryOperation(let function, let description):
                if result != nil {
                    pendingOperation = PendingBinaryOperation(description: description, function: function, firstOperand: result!)
                    result = nil
                }
            case .equals:
                if pendingOperation != nil && result != nil{
                    result = pendingOperation?.perform(with: result!)
                    pendingOperation = nil
                }
            }
        }

        for entry in sequence {
            switch entry{
            case .operand(let value):
                result = (value, "\(value)")
            case .operation(let operation):
                performOperation(operation)
            case .variable(let variable):
                if let dictionary = variables {
                    result = (dictionary[variable] ?? 0, variable)
                } else {
                    result = (0, variable)
                }
            }
        }
        
        if isPending {
            return (result?.0, isPending, pendingOperation!.description(pendingOperation!.firstOperand.1, result?.1 ?? ""))
        } else {
            return (result?.0, isPending, result?.1 ?? "")
        }
        
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
    
    mutating func undo(){
        if !sequence.isEmpty{
            sequence.removeLast()
        }
    }
    
    @available(iOS, deprecated, message: "irrelevant, use evaluate()")
    var result: Double? {
        get {
            if accumulator != nil {
                return accumulator!.0
            } else {
                return nil
            }
        }
    }
    
    @available(iOS, deprecated, message: "irrelevant, use evaluate()")
    var resultIsPending: Bool {
        get {
            if pendingBinaryOperation != nil {
                return true
            } else {
                return false
            }
        }
    }
    
    @available(iOS, deprecated, message: "irrelevant, use evaluate()")
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
