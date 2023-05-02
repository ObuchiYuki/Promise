//
//  Promise+Combination.swift
//
//
//  Created by yuki on 2021/08/12.
//

extension Promise {
    public func combine<A>(_ a: Promise<A, Failure>) -> Promise<(Output, A), Failure> {
        Promise.combine(self, a)
    }
    public func combine<A, B>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>) -> Promise<(Output, A, B), Failure> {
        Promise.combine(self, a, b)
    }
    public func combine<A, B, C>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>, _ c: Promise<C, Failure>) -> Promise<(Output, A, B, C), Failure> {
        Promise.combine(self, a, b, c)
    }
}

extension Promise {
    public static func combine<A, B>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>) -> Promise<(A, B), Failure> {
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
    
    public static func combine<A, B, C>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>, _ c: Promise<C, Failure>) -> Promise<(A, B, C), Failure> {
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
    
    public static func combine<A, B, C, D>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>, _ c: Promise<C, Failure>, _ d: Promise<D, Failure>) -> Promise<(A, B, C, D), Failure> {
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
}


extension Array where Element: _PromiseCombineAllInterface {
    public func combineAll() -> Promise<[Element.Output], Element.Failure> {
        Element.combineAll(self)
    }
}

public protocol _PromiseCombineAllInterface {
    associatedtype Output
    associatedtype Failure: Error
    
    static func combineAll(_ promises: [Self]) -> Promise<[Output], Failure>
}

extension Promise: _PromiseCombineAllInterface {
    public static func combineAll(_ promises: [Promise<Output, Failure>]) -> Promise<[Output], Failure> {
        if promises.isEmpty { return Promise<[Output], Failure>(output: []) }
        
        return Promise<[Output], Failure> { resolve, reject in
            var outputs = [Output?](repeating: nil, count: promises.count)
            var hasRejected = false
            
            for (i, promise) in promises.enumerated() {
                promise.sink({ output in
                    if hasRejected { return }
                    outputs[i] = output
                    if let outputs = outputs as? [Output] { resolve(outputs) }
                }, { failure in
                    if hasRejected { return }
                    hasRejected = true
                    reject(failure)
                })
            }
        }
    }
    
}
