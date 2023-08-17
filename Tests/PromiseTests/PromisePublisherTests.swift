//
//  File.swift
//
//
//  Created by yuki on 2023/05/27.
//

#if canImport(Combine)
import XCTest
import Combine
import Promise

final class PromisePublisherTests: XCTestCase {
    func testPublisherPromise_Just() {
        var fulfilled = false
        Just(123).firstValue()
            .sink{
                fulfilled = true
                XCTAssertEqual($0, 123)
            }
        XCTAssert(fulfilled)
    }
    
    func testPublisherPromise_Empty() {
        var fulfilled = false
        Empty<Int, Never>().firstValue()
            .sink{
                fulfilled = true
                XCTAssertEqual($0, nil)
            }
        XCTAssert(fulfilled)
    }
    
    func testPublisherPromise_Combined() {
        var fulfilled = false
        Just(1).combineLatest(Just(2), Just(3))
            .firstValue()
            .tryPeek{
                fulfilled = true
                XCTAssert(try XCTUnwrap($0) == (1, 2, 3))
            }
            .catch{_ in XCTFail() }
        XCTAssert(fulfilled)
    }
}

#endif
