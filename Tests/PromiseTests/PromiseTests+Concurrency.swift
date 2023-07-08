//
//  File.swift
//  
//
//  Created by yuki on 2023/05/27.
//

import XCTest
@testable import Promise

final class PromiseTestsConcurrency: XCTestCase {
    
    func testAsyncPromise() async {
        _ = await Promise.combineAll([
            Promise.wait(for: 0.1),
            Promise.wait(for: 0.1)
        ])
        .measureInterval{ XCTAssert($0 < 0.11) }
        .value
    }
    
    func testNestedPromiseWithAsyncContext() async throws {        
        let value = await Promise{
            await Promise{
                await Promise<Int, Never>.resolve(10).value
            }.value
        }.value

        XCTAssertEqual(value, 10)
    }

    func testNestedPromiseWithAsyncContextWithError() async throws {
        var throwed = false
        do {
            try await Promise{
                try await Promise{
                    throw PromiseTestError()
                }.value
            }.value
        } catch {
            throwed = true
        }
        XCTAssert(throwed)
    }

    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    func testMakePromiseFromAsyncContext() throws {
//        let end = expectation(description: "end")
//        
//        let waitPromise = Promise{
//            await Promise.wait(for: .milliseconds(1)).value
//        }
//        
//        waitPromise
//            .assertNoFailure()
//            .sink{
//                end.fulfill()
//            }
//        
//        wait(for: [end])
    }
}
