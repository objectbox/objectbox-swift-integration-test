//
//  IntTestiOSRegularTests.swift
//  IntTestiOSRegularTests
//
//  Created by objectbox on 12.09.19.
//  Copyright © 2019 objectbox. All rights reserved.
//

import XCTest
@testable import IntTestiOSRegular
import ObjectBox

class IntTestiOSRegularTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let store = try! Store(directoryPath: "objectbox")
        try! store.closeAndDeleteAllFiles()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
