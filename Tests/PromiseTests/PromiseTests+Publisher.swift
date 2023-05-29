//
//  File.swift
//
//
//  Created by yuki on 2023/05/27.
//

#if canImport(Combine)
import XCTest
import Combine
@testable import Promise

final class PromiseTestsPublisher: XCTestCase {
    func testJustWithPromise() {
        let pub = PassthroughSubject<Int, Never>()
            
        pub.last().firstValue().sink{ print($0) }
        
        pub.send(1)
        pub.send(2)
        pub.send(3)
        pub.send(completion: .finished)
    }
}

#endif
