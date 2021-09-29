//
//  Promise+Debug.swift
//  CoreUtil
//
//  Created by yuki on 2021/08/23.
//  Copyright © 2021 yuki. All rights reserved.
//

import Foundation

extension Promise {
    public func breakpoint() -> Promise<Output, Failure> {
        self.catch{ error in
            print(error)
            raise(SIGTRAP)
        }
        return self
    }
    
    public func measure(label: String) -> Promise<Output, Failure> {
        let start = Date()
        self.finally{
            let end = Date()
            let interval = end.timeIntervalSince(start)
            print("[\(label)] \(interval) s")
        }
        return self
    }
}
