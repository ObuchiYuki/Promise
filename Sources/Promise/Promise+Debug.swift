//
//  Promise+Debug.swift
//  CoreUtil
//
//  Created by yuki on 2021/08/23.
//  Copyright © 2021 yuki. All rights reserved.
//

import Foundation

extension Promise {
    @inlinable public func breakpoint() -> Promise<Output, Failure> {
        self.catch{ error in
            Swift.print(error)
            raise(SIGTRAP)
        }
        return self
    }
    
    @inlinable public func measure(label: String) -> Promise<Output, Failure> {
        let start = Date()
        self.finally{
            let end = Date()
            let interval = end.timeIntervalSince(start)
            Swift.print("[\(label)] \(interval) s")
        }
        return self
    }
    
    @inlinable public func print(_ prefix: String?) -> Promise<Output, Failure> {
        func printPrefix() {
            if let prefix = prefix { Swift.print("\(prefix): ", terminator: "") }
        }
        self.sink({ output in
            printPrefix()
            Swift.print("receive output:", "(\(output))")
        }, { failure in
            printPrefix()
            Swift.print("receive failure:", "(\(failure))")
        })
        return self
    }
}
