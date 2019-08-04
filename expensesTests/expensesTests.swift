//
//  expensesTests.swift
//  helperTests
//
//  Created by Antonio Santos on 8/3/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import XCTest
@testable import expenses

class helperTests: XCTestCase {
//    enum Error {
//        case TypeError
//    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNumberFormatterFailsIfStringDoesNotConvertToDouble() {
        let numberString = "FooBar"
        
        XCTAssertThrowsError(try Helper.formatNumber(numberString))
    }

    func testNumberFormatterShouldReturnStringFormattedAsCurrency() {
        // Given
        let numberString = "15999"
        
        // When
        let formattedString = try? Helper.formatNumber(numberString)
        
        // Then
        XCTAssertEqual("$159.99", formattedString)
    }

}
