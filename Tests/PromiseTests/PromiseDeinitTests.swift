//
//  File.swift
//  
//
//  Created by yuki on 2024/05/27.
//

import XCTest
import Promise

final class PromiseDeinitTests: XCTestCase {
    func testDeinit_withoutResolveAndReject() {
        var failed = false
        do {
            let promise = Promise<Void, Error>
                .optionallyResolving { resolve, reject in }
            
            promise.catch {_ in
                failed = true
            }
        }
        
        XCTAssert(failed)
    }
    
    func testDeinit_withResolve() {
        var failed = false
        do {
            let promise = Promise<Void, Error>
                .optionallyResolving { resolve, reject in
                    resolve(())
                }
            
            promise.catch {_ in
                failed = true
            }
        }
        
        XCTAssertFalse(failed)
    }
}
