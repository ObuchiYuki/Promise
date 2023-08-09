//
//  Promise+Test.swift
//  
//
//  Created by yuki on 2023/08/09.
//

#if canImport(XCTest)
import XCTest

extension Promise {
    public func waitUntilExit(_ testCase: XCTestCase, timeout: TimeInterval = 1) {
        let expectation = testCase.expectation(description: "Promise should exit")
        self.finally{ expectation.fulfill() }
        testCase.wait(for: [expectation], timeout: timeout)
    }
}
#endif
