//
//  File.swift
//  
//
//  Created by yuki on 2023/05/27.
//

import XCTest
@testable import Promise

final class PromiseTestsConcurrency: XCTestCase {
    
    func testNestedPromiseWithAsyncContext() async throws {
        
        let value = await Promise{
            await Promise{
                return await Promise<Int, Never>.resolve(10).value()
            }.value()
        }.value()

        XCTAssertEqual(value, 10)
    }

    func testNestedPromiseWithAsyncContextWithError() async throws {
        var throwed = false
        do {
            try await Promise{
                try await Promise{
                    throw PromiseTestError()
                }.value()
            }.value()
        } catch {
            throwed = true
        }
        XCTAssert(throwed)
    }

    
    @available(macOS 13, *)
    func testMakePromiseFromAsyncContext() throws {
        let end = expectation(description: "end")
        
        let waitPromise = Promise{
            try await Task.sleep(for: .milliseconds(10))
        }
        
        waitPromise
            .assertNoFailure()
            .sink{
                end.fulfill()
            }
        
        wait(for: [end])
    }
}
