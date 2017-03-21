//
//  ViewController.swift
//  Calculator
//
//  Created by Michael Hyun on 2/23/17.
//  Copyright © 2017 Michael Hyun. All rights reserved.
//


import UIKit

class CalculatorController: UIViewController {
    
    @IBOutlet weak var operationMemory: UILabel!
    @IBOutlet private weak var display: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    var decimalAlreadyPressed = false

    @IBAction func addDecimal(_ sender: UIButton) {
        let currentMemory = operationMemory!.text!
        operationMemory!.text = currentMemory + sender.currentTitle!
        if (userIsInTheMiddleOfTyping == true) || (display!.text! == "0"){
            if decimalAlreadyPressed == false{
                display.text = display!.text! + "."
                decimalAlreadyPressed = true
        }
        }
    }
    

    @IBAction func storeVariable(_ sender: UIButton) {
        brain.variableValues[sender.currentTitle!] = displayValue
        if userIsInTheMiddleOfTyping {
            userIsInTheMiddleOfTyping = false
        } else {
            brain.undo()
        }
        brain.program = brain.program

        displayValue = brain.result

    }
    @IBAction func getVariable(_ sender: UIButton) {
        brain.setOperand(variableName: sender.currentTitle!)
        userIsInTheMiddleOfTyping = false
        displayValue = brain.result

    }

    
    @IBAction func undo(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping != true {
            brain.undo()
            return
        }
        
        guard var number = display.text else {
            return
        }
        
        number.remove(at: number.index(before: number.endIndex))
        if number.isEmpty {
            number = "0"
            userIsInTheMiddleOfTyping = false
        }
        display.text = number
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let currentMemory = operationMemory!.text!
        operationMemory!.text = currentMemory + sender.currentTitle!
        if userIsInTheMiddleOfTyping{
            let textCurrentlyInDisplay = display!.text!
            display!.text = textCurrentlyInDisplay + digit
        }
        else{
            display!.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue: Double{
        get{
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    
    @IBAction func memoryOperation(_ sender: UIButton) {
        let currentMemory = operationMemory!.text!
        operationMemory!.text = currentMemory + sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let memorySymbol = sender.currentTitle{
            brain.performMemoryOperation(symbol: memorySymbol)
        }
        displayValue = brain.result
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        decimalAlreadyPressed = false
        let currentMemory = operationMemory!.text!
        operationMemory!.text = currentMemory + sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle{
            brain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.result
    }
}
