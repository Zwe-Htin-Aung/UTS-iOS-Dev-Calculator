//
//  main.swift
//  calc
//
//  Created by Jesse Clark on 12/3/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import Foundation

var args = ProcessInfo.processInfo.arguments
args.removeFirst() // Remove the name of the program
var showSteps : Bool = false; // "false" to satisfy tests, "true" to show working
var numbers : [Int] = []; // Filtered numbers from expression
var operators : [String] = []; // Filtered operations from expression
var result : String = "";
let capturedExpression = currentExpression(); // Show captured expression

if showSteps { print("\n" + capturedExpression); }

do{
    try handleOneArg(); // Handle case when there is only one value in expression
    // Main functions of validation and calculation
    while args.count != 1 {
        try filterExpression(); // Sort and validate numbers and operators
        try validateExpression(); // Check if expression ends with number & NOT operator
        if let firstOp : Int = findFirstStep() { // Check which operator to calculate first
            try calculateResult(opIndex: firstOp) // Calculate result with numbers and operators step by step
        } else {
            throw CalculatorError.invalidOperator;
        }
        reformExpression(); // Reform Expression after calculation
    }
    displayOutcome(); // Display Result
} catch CalculatorError.invalidNumber { // Error for invalid number inputs e.g. ./calc c +
    print("Invalid Number Input! Please follow the pattern: \"num operator num operator... operator num\", separated by space!");
    exit(1);
} catch CalculatorError.invalidOperator { // Error for invalid operator inputs e.g. ./calc 5 b , ./calc 5 5
    print("Invalid Operator Input! Only allows +, -, x, /, % . Please follow the pattern: \"num operator num operator... operator num\", separated by space!");
    exit(1);
} catch CalculatorError.invalidExpression { // Error for invalid expression e.g ./calc 4 -
    print("Invalid Expression! Please follow the pattern: \"num operator num operator... operator num\", separated by space, ending with a number!");
    exit(1);
} catch CalculatorError.denominatorZero { // Error for denominator being zero in modulus and division e.g. ./calc 49 / 0
    print("Denominator of a division or modulus cannot be \"0\"!")
    exit(1);
}

// Function to handle one argument input
func handleOneArg() throws {
    if args.count == 1 {
        try filterExpression(); // Validate single value expression
        result = String(numbers[0]);
    }
}

// Function to get the current expression
func currentExpression() -> String {
    var expression : String = "";
    for arg in args {
        expression.append(arg + " ");
    }
    return expression;
}

// Function to separate numbers and operations from expression
func filterExpression() throws {
    for i in 0 ..< args.count {
        if (i % 2) == 0 { // Point at number slot in expression
            if let num = Int(args[i]) { // Check if number is valid, if so continue
                numbers.append(num);
            } else {
                throw CalculatorError.invalidNumber; // Throw Error Message for Invalid Number
            }
        } else { // Point at operator slot in expression
            switch args[i] { // Check if operator is valid, if so continue
            case "x","/","%","+","-":
                operators.append(args[i]);
            default:
                throw CalculatorError.invalidOperator; // Throw Error Message for Invalid Operator
            }
        }
    }
}

// Function to check if expression is valid
func validateExpression() throws {
    if numbers.count == operators.count {
        // Throw Error Message for Invalid Expression ending in operator
        throw CalculatorError.invalidExpression;
    }
}

// Function to check which operator to calculate first
func findFirstStep() -> Int? {
    for i in 0 ..< operators.count {
        for op in ["x", "/", "%"] {
            if operators[i] == op {
                return i;
            }
        }
    }
    for i in 0 ..< operators.count {
        for op in ["+", "-"] {
            if operators[i] == op {
                return i;
            }
        }
    }
    return nil;
}

// Function to calculate result using index of operator to use first
func calculateResult(opIndex : Int) throws {
    let num1 : Int = numbers[opIndex];
    let num2 : Int = numbers[opIndex + 1];
    var stepResult : Int = 0;
    
    // Calculate the first operator and pair of numbers
    let calculator = Calculator(); // Initialize a Calculator object
    switch operators[opIndex] {
    case "x":
        stepResult = calculator.multiply(no1: num1, no2: num2) // Calculate multiplication
    case "/":
        if(num2) == 0 { throw CalculatorError.denominatorZero; } // Show Error Message when denominator is "0"
        stepResult = calculator.divide(no1: num1, no2: num2) // Calculate division
    case "%":
        if(num2) == 0 { throw CalculatorError.denominatorZero; } // Show Error Message when denominator is "0"
        stepResult = calculator.modulus(no1: num1, no2: num2) // Calculate modulus
    case "+":
        stepResult = calculator.add(no1: num1, no2: num2) // Calculate addition
    case "-":
        stepResult = calculator.subtract(no1: num1, no2: num2) // Calculate subtraction
    default:
        throw CalculatorError.invalidOperator; // Error catching operator
    }
    
    // Update numbers and operators after calculation one step
    numbers[opIndex] = stepResult;
    numbers.remove(at: opIndex + 1);
    operators.remove(at: opIndex);
}

// Function to rewrite the expression after each step being calculated
func reformExpression() {
    args.removeAll();
    for i in 0 ..< numbers.count {
        args.append(String(numbers[i]));
        if i < operators.count {
            args.append(operators[i]);
        }
    }
    numbers.removeAll();
    operators.removeAll();
    result = args[0];
    if showSteps { print(currentExpression()); /* Show expression after current step */ }
}

// Function to display result
func displayOutcome() {
    if showSteps { print("\nResult of \(capturedExpression)is \(result)\n"); }
    else { print(result); }
}

// Calculate Error Definitions
enum CalculatorError : Error {
    case invalidNumber
    case invalidOperator
    case invalidExpression
    case denominatorZero
}
