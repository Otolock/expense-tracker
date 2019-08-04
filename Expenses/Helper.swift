//
//  Helper.swift
//  expenses
//
//  Created by Antonio Santos on 8/3/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import Foundation

class Helper {
    enum FormatNumberError: Error {
        case InvalidString
    }
    
    /// Takes a string argument and returns a Double with decimal points formatted from right to left.
    ///  Input 1234 would result in 12.34
    /// - Parameter from: Any string that can be converted to a double.
    static func formatNumber(_ from: String) throws -> String {
        guard let number = Double(from) else {
            throw FormatNumberError.InvalidString
        }
        
        let decimalNumber = number / 100.00
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        return numberFormatter.string(from: decimalNumber as NSNumber) ?? "0.00"
    }
    
    /// Takes a string formatted as a dollar value and appends a new number to return as the new dollar value
    /// - Parameter from: The formatted string to work from
    /// - Parameter add: The number to be added to the strings
    static func updateFormattedNumber(from: String, add: String) -> String {
        let MAX_LENGTH = 10
        let removedPunctuation = from.replacingOccurrences(of: "[.$,]", with: "", options: .regularExpression)
        
        // limit max number to $999,999,999.99
        if (removedPunctuation.count <= MAX_LENGTH) {
            return(try! formatNumber(removedPunctuation + add))
        } else {
            return (try! formatNumber(removedPunctuation))
        }
    }
}
