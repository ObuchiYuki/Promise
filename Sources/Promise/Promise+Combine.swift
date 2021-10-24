//
//  Promise+Operators.swift
//  CoreUtil
//
//  Created by yuki on 2021/08/12.
//  Copyright © 2021 yuki. All rights reserved.
//

extension Promise {
    @inlinable public func combine<A>(_ a: Promise<A, Failure>) -> Promise<(Output, A), Failure> {
        Promise.combine(self, a)
    }
    @inlinable public func combine<A, B>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>) -> Promise<(Output, A, B), Failure> {
        Promise.combine(self, a, b)
    }
    @inlinable public func combine<A, B, C>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>, _ c: Promise<C, Failure>) -> Promise<(Output, A, B, C), Failure> {
        Promise.combine(self, a, b, c)
    }
}

extension Array {
    @inlinable public func combine<Output, Failure>() -> Promise<[Output], Failure> where Element == Promise<Output, Failure> {
        Promise.combineCollection(self)
    }
}

extension Promise {
    @inlinable public static func combine<A, B>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>) -> Promise<(A, B), Failure> {
        Promise<(A, B), Failure>{ resolve, reject in
            var outputA: A?
            var outputB: B?
            var hasCompleted = false
            func checkResolve() {
                if !hasCompleted, let outputA = outputA, let outputB = outputB {
                    hasCompleted = true
                    resolve((outputA, outputB))
                }
            }
            func rejectIfNeeded(_ failure: Failure) {
                if hasCompleted { return }; hasCompleted = true
                reject(failure)
            }
            
            a.sink({ outputA = $0; checkResolve() }, rejectIfNeeded)
            b.sink({ outputB = $0; checkResolve() }, rejectIfNeeded)
        }
    }
    
    @inlinable public static func combine<A, B, C>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>, _ c: Promise<C, Failure>) -> Promise<(A, B, C), Failure> {
        Promise<(A, B, C), Failure>{ resolve, reject in
            var outputA: A?
            var outputB: B?
            var outputC: C?
            var hasCompleted = false
            func checkResolve() {
                if !hasCompleted, let outputA = outputA, let outputB = outputB, let outputC = outputC {
                    hasCompleted = true
                    resolve((outputA, outputB, outputC))
                }
            }
            func rejectIfNeeded(_ failure: Failure) {
                if hasCompleted { return }; hasCompleted = true
                reject(failure)
            }
            
            a.sink({ outputA = $0; checkResolve() }, rejectIfNeeded)
            b.sink({ outputB = $0; checkResolve() }, rejectIfNeeded)
            c.sink({ outputC = $0; checkResolve() }, rejectIfNeeded)
        }
    }
    
    @inlinable public static func combine<A, B, C, D>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>, _ c: Promise<C, Failure>, _ d: Promise<D, Failure>) -> Promise<(A, B, C, D), Failure> {
        Promise<(A, B, C, D), Failure>{ resolve, reject in
            var outputA: A?
            var outputB: B?
            var outputC: C?
            var outputD: D?
            var hasCompleted = false
            func checkResolve() {
                if !hasCompleted, let outputA = outputA, let outputB = outputB, let outputC = outputC, let outputD = outputD {
                    hasCompleted = true
                    resolve((outputA, outputB, outputC, outputD))
                }
            }
            func rejectIfNeeded(_ failure: Failure) {
                if hasCompleted { return }; hasCompleted = true
                reject(failure)
            }
            
            a.sink({ outputA = $0; checkResolve() }, rejectIfNeeded)
            b.sink({ outputB = $0; checkResolve() }, rejectIfNeeded)
            c.sink({ outputC = $0; checkResolve() }, rejectIfNeeded)
            d.sink({ outputD = $0; checkResolve() }, rejectIfNeeded)
        }
    }
    
    @inlinable public static func combineCollection(_ promises: [Promise<Output, Failure>]) -> Promise<[Output], Failure> {
        Promise<[Output], Failure> { resolve, reject in
            var outputs = [Output?](repeating: nil, count: promises.count)
            var settles = 0
            var hasRejected = false
            
            for (i, promise) in promises.enumerated() {
                promise.sink({ output in
                    if hasRejected { return }
                    outputs[i] = output
                    settles += 1
                    
                    if settles == promises.count {
                        resolve(outputs.compactMap{ $0 })
                    }
                }, { failure in
                    if hasRejected { return }; hasRejected = true
                    
                    reject(failure)
                })
            }
        }
    }
}
