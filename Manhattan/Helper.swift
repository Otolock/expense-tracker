//
//  Helper.swift
//  Manhattan
//
//  Created by Antonio Santos on 8/3/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import Foundation
import CoreData

class Helper {
    enum ConversionError: Error {
        case InvalidString
        case UnknownError
    }
    
    /// Converts a string numeral such as "$15.99" and adds the number given to it to return "$159.9x"
    /// - Parameter from: A string represented the number to work from.
    /// - Parameter add: A string representing the number to be added.
    static func convertStringNumeralToCurrency(from: String, add: String) throws -> String {
        let mutatedFrom = removePunctuation(from) + add
        
        guard let number = Double(mutatedFrom) else {
            throw ConversionError.InvalidString
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        let decimalNumber = (number / 100)
        let formattedString = numberFormatter.string(from: NSNumber(value: decimalNumber))
        
        return formattedString!
    }
    
    
    /// Removes all - , . $ symbols from a String
    /// - Parameter from: The string to remove punctuation from.
    static func removePunctuation(_ from: String) -> String {
        let punctuationRegex = "[-,.$]"
        
        return from.replacingOccurrences(of: punctuationRegex, with: "", options: .regularExpression)
    }
    
    /// Detects if app is launching for the first time.
    static func isFirstLaunch() -> Bool {
        let defaults = UserDefaults.standard
        
        if let _ = defaults.string(forKey: "hasAppAlreadyLaunchedOnce") {
            return false
        } else {
            defaults.set(true, forKey: "hasAppAlreadyLaunchedOnce")
            return true
        }
    }
    
    static func doesEntityExist(entity: String, with predicate: String, container: NSPersistentContainer) -> Bool {
        let request = NSFetchRequest<NSManagedObject>(entityName: entity)

        // create an NSPredicate to get the instance you want to make change
        let predicate = NSPredicate(format: "name = %@", predicate)
        request.predicate = predicate
        
        do {
            let results = try container.viewContext.fetch(request)
            return results.count > 0
        } catch let error {
            print(error.localizedDescription)
            return false
        }
    }
}
