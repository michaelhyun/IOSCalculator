//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michael Hyun on 2/23/17.
//  Copyright © 2017 Michael Hyun. All rights reserved.
//

import Foundation

enum Optional<T>{
    case None
    case Some(T)
}

class CalculatorBrain{
    
    private var accumulator = 0.0
    private var clearedOnceAlready = false;
    private var internalProgram = [Any]()
    var variableValues: Dictionary<String, Double> = [:]

    
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                                    pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Precedence.Max
            }
        }
    }
    
    private var currentPrecedence = Precedence.Max
    
    private enum Precedence: Int {
        case Min = 0, Max
    }

    
    func setOperand(operand:Double){
        accumulator = operand
        clearedOnceAlready = false;
        internalProgram.append(operand)
    }
    
    func setOperand(variableName: String) {
        variableValues[variableName] = variableValues[variableName] ?? 0.0
        accumulator = variableValues[variableName]!
        descriptionAccumulator = variableName
        internalProgram.append(variableName)
    }
    
    private var operations: Dictionary<String, Operation> = [
        "∏": Operation.Constant(M_PI), // M_PI
        "e": Operation.Constant(M_E), // M_E
        "±" : Operation.UnaryOperation({ -$0 }, { "-(\($0))"}),
        "√" : Operation.UnaryOperation(sqrt, { "√(\($0))"}),
        "cos" : Operation.UnaryOperation(cos, { "cos(\($0))"}),
        "sin": Operation.UnaryOperation(sin,{"sin(\($0))"}),
        "tan": Operation.UnaryOperation(tan, {"tan(\($0))"}),
        "×" : Operation.BinaryOperation({ $0 * $1 }, { "\($0) × \($1)"}, Precedence.Max),
        "÷" : Operation.BinaryOperation({ $0 / $1 }, { "\($0) ÷ \($1)"}, Precedence.Max),
        "+" : Operation.BinaryOperation({ $0 + $1 }, { "\($0) + \($1)"}, Precedence.Min),
        "−" : Operation.BinaryOperation({ $0 - $1 }, { "\($0) - \($1)"}, Precedence.Min),
        "SQ": Operation.UnaryOperation({$0 * $0}, {"(\($0))"}),
        "CU": Operation.UnaryOperation({$0 * $0 * $0}, {"(\($0))"}),
        "C" : Operation.Clear,
        "=": Operation.Equals
    ]
    
    private enum Operation{
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, Precedence)
        case Equals
        case Clear
    }
    
    private var memoryVar = 0.0
    
    func performMemoryOperation(symbol: String?){
        if let memOperation = symbol{
            switch memOperation{
                case "MR":
                accumulator = memoryVar
                case "MS":
                memoryVar = accumulator
                case "M+":
                memoryVar = accumulator + memoryVar
                case "MC":
                memoryVar = 0.0
                default:
                break
                
            }
        }
    }
    
    func undo() {
        if !internalProgram.isEmpty {
            internalProgram.removeLast()
            program = internalProgram
        } else {
            clearCalculator()
            descriptionAccumulator = ""
        }
    }
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .UnaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation(let function, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                if currentPrecedence.rawValue < precedence.rawValue {
                    descriptionAccumulator = "(\(descriptionAccumulator))"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator,
                                                     descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .Equals:
                executePendingBinaryOperation()
            case .Clear:
                clearCalculator()
            }
        }
    }


    
    private func clearCalculator(){
        if clearedOnceAlready{ //all clear
            pending = nil
            accumulator = 0.0
            internalProgram.removeAll()
            clearedOnceAlready = false
        }
        else{ //clear
            accumulator = 0.0
            clearedOnceAlready = true
        }
        
    }
    
    private func executePendingBinaryOperation(){
        
        if pending != nil{
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo{
        var binaryFunction:(Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String

    }
    
    typealias PropertyList = Any
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clearCalculator()
            if let arrayOfOps = newValue as? [Any] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let variableName = op as? String {
                        if variableValues[variableName] != nil {
                            setOperand(variableName: variableName)
                        } else if let operation = op as? String {
                            performOperation(symbol: operation)
                        }
                    }
                }
            }
        }
    }
    
    
    var result: Double{
        get{
            return accumulator
        }
    }
}
