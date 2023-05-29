//
//  Promise+Combination.swift
//
//
//  Created by yuki on 2021/08/12.
//

extension Promise {
    public func merge(_ a: Promise<Output, Failure>) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        self.subscribe(promise.fulfill, promise.reject)
        a.subscribe(promise.fulfill, promise.reject)
        return promise
    }
    
    public func merge(_ a: Promise<Output, Failure>, _ b: Promise<Output, Failure>) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        self.subscribe(promise.fulfill, promise.reject)
        a.subscribe(promise.fulfill, promise.reject)
        b.subscribe(promise.fulfill, promise.reject)
        return promise
    }
    
    public func merge(_ a: Promise<Output, Failure>, _ b: Promise<Output, Failure>, _ c: Promise<Output, Failure>) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        self.subscribe(promise.fulfill, promise.reject)
        a.subscribe(promise.fulfill, promise.reject)
        b.subscribe(promise.fulfill, promise.reject)
        c.subscribe(promise.fulfill, promise.reject)
        return promise
    }
}

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


extension Array where Element: _PromiseCombineInterface {
    public func mergeAll() -> Promise<Element.Output, Element.Failure> {
        Element._mergeAll(self)
    }
    
    public func combineAll() -> Promise<[Element.Output], Element.Failure> {
        Element._combineAll(self)
    }
}

public protocol _PromiseCombineInterface {
    associatedtype Output
    associatedtype Failure: Error
    
    static func _combineAll(_ promises: [Self]) -> Promise<[Output], Failure>
    static func _mergeAll(_ promises: [Self]) -> Promise<Output, Failure>
}

extension Promise: _PromiseCombineInterface {
    public static func _mergeAll(_ promises: [Promise<Output, Failure>]) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        
        for sub in promises {
            sub.subscribe(promise.fulfill, promise.reject)
        }
        
        return promise
    }
    
    public static func _combineAll(_ promises: [Promise<Output, Failure>]) -> Promise<[Output], Failure> {
        if promises.isEmpty { return Promise<[Output], Failure>.resolve([]) }
        
        return Promise<[Output], Failure> { resolve, reject in
            let count = promises.count
            var outputs = [Output?](repeating: nil, count: count)
            var dp = [Bool](repeating: false, count: count)
            var fulfilled = 0
            var hasRejected = false
            var hasFulfilled = false
            
            for (i, promise) in promises.enumerated() {
                promise.sink({ output in
                    if hasRejected || hasFulfilled { return }
                    if dp[i] == false {
                        dp[i] = true
                        fulfilled += 1
                    }
                    outputs[i] = output
                    if fulfilled == count {
                        hasFulfilled = true
                        resolve(outputs as! [Output])
                    }
                }, { failure in
                    if hasRejected || hasFulfilled { return }
                    hasRejected = true
                    reject(failure)
                })
            }
        }
    }
    
}
