//
//  expensesTests.swift
//  convertStringNumeralToCurrencyTests
//
//  Created by Antonio Santos on 8/3/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import XCTest
@testable import expenses

class convertStringNumeralToCurrencyTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testShouldThrowErrorIfGivenAnInvalidString() {
        // Given
        let testString = "FooBar"

        XCTAssertThrowsError(try Helper.convertStringNumeralToCurrency(from: testString, add: ""), Helper.ConversionError.InvalidString.localizedDescription)
    }
    
    func testShouldReturnStringFormattedAsCurrency() {
        let testString = "159"
        
        let result = try? Helper.convertStringNumeralToCurrency(from: testString, add: "")
        
        XCTAssertEqual(result, "$1.59")
    }
    
    func testShouldHandleStringsWithSymbolsAndPunctuation() {
        let oldString = try? Helper.convertStringNumeralToCurrency(from: "159", add: "")
        
        let newString = try? Helper.convertStringNumeralToCurrency(from: oldString!, add: "")
        
        XCTAssertEqual(newString, "$1.59")
    }
    
    func testShouldAddStringPassedAsArgument() {
        let oldString = "$1.59"
        
        let newString = try? Helper.convertStringNumeralToCurrency(from: oldString, add: "9")
        
        XCTAssertEqual(newString, "$15.99")
    }
}

class removePunctuationTests: XCTestCase {
    func testShouldRemovePunctuationFromString() {
        // Given
        let testString = "-$15.99"

        // When
        let result = Helper.removePunctuation(testString)

        // Then
        XCTAssertEqual(result, "1599")
    }
}
