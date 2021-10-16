//
//  Promise+Wait.swift
//  CoreUtil
//
//  Created by yuki on 2021/08/23.
//  Copyright © 2021 yuki. All rights reserved.
//

import Foundation

extension Promise {
    public func wait(on queue: DispatchQueue = .main, for interval: TimeInterval) -> Promise<Output, Failure> {
        Promise { resolve, reject in
            self.sink({ output in
                queue.asyncAfter(deadline: .now() + interval) { resolve(output) }
            }, { failure in
                queue.asyncAfter(deadline: .now() + interval) { reject(failure) }
            })
        }
    }
    
    public static func wait(on queue: DispatchQueue = .main, for interval: TimeInterval) -> Promise<Output, Failure> where Output == Void, Failure == Never {
        Promise(output: ()).wait(on: queue, for: interval)
    }
    
    public func wait<T, F>(for promise: Promise<T, F>) -> Promise<Output, Error> {
        Promise<Output, Error> { resolve, reject in
            self.sink({ output in promise.sink({_ in resolve(output) }, reject) }, reject)
        }
    }
}
