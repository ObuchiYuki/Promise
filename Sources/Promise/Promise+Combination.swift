//
//  Promise+Combination.swift
//
//
//  Created by yuki on 2021/08/12.
//

extension Promise {
    public func merge(_ a: Promise<Output, Failure>) -> Promise<Output, Failure> {
        Promise.merge(self, a)
    }
    
    public func merge(_ a: Promise<Output, Failure>, _ b: Promise<Output, Failure>) -> Promise<Output, Failure> {
        Promise.merge(self, a, b)
    }
    
    public func merge(_ a: Promise<Output, Failure>, _ b: Promise<Output, Failure>, _ c: Promise<Output, Failure>) -> Promise<Output, Failure> {
        Promise.merge(self, a, b, c)
    }
    
    public static func merge(_ a: Promise<Output, Failure>, _ b: Promise<Output, Failure>) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        a.subscribe(promise.fulfill, promise.reject)
        b.subscribe(promise.fulfill, promise.reject)
        return promise
    }
    
    public static func merge(_ a: Promise<Output, Failure>, _ b: Promise<Output, Failure>, _ c: Promise<Output, Failure>) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        a.subscribe(promise.fulfill, promise.reject)
        b.subscribe(promise.fulfill, promise.reject)
        c.subscribe(promise.fulfill, promise.reject)
        return promise
    }
    
    public static func merge(_ a: Promise<Output, Failure>, _ b: Promise<Output, Failure>, _ c: Promise<Output, Failure>, _ d: Promise<Output, Failure>) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        a.subscribe(promise.fulfill, promise.reject)
        b.subscribe(promise.fulfill, promise.reject)
        c.subscribe(promise.fulfill, promise.reject)
        d.subscribe(promise.fulfill, promise.reject)
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
            var outputA: A?, outputB: B?
            func check() {
                guard let outputA = outputA, let outputB = outputB else { return }
                resolve((outputA, outputB))
            }
            a.subscribe({ outputA = $0; check() }, reject)
            b.subscribe({ outputB = $0; check() }, reject)
        }
    }
    
    public static func combine<A, B, C>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>, _ c: Promise<C, Failure>) -> Promise<(A, B, C), Failure> {
        Promise<(A, B, C), Failure>{ resolve, reject in
            var outputA: A?, outputB: B?, outputC: C?
            func check() {
                guard let outputA = outputA, let outputB = outputB, let outputC = outputC else { return }
                resolve((outputA, outputB, outputC))
            }
            a.subscribe({ outputA = $0; check() }, reject)
            b.subscribe({ outputB = $0; check() }, reject)
            c.subscribe({ outputC = $0; check() }, reject)
        }
    }
    
    public static func combine<A, B, C, D>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>, _ c: Promise<C, Failure>, _ d: Promise<D, Failure>) -> Promise<(A, B, C, D), Failure> {
        Promise<(A, B, C, D), Failure>{ resolve, reject in
            var outputA: A?, outputB: B?, outputC: C?, outputD: D?
            func check() {
                guard let outputA = outputA, let outputB = outputB, let outputC = outputC, let outputD = outputD else { return }
                resolve((outputA, outputB, outputC, outputD))
            }
            a.subscribe({ outputA = $0; check() }, reject)
            b.subscribe({ outputB = $0; check() }, reject)
            c.subscribe({ outputC = $0; check() }, reject)
            d.subscribe({ outputD = $0; check() }, reject)
        }
    }
}


extension Array where Element: _PromiseCombineInterface {
    public func mergeAll() -> Promise<Element.Output, Element.Failure> {
        Element.mergeAll(self)
    }
    
    public func combineAll() -> Promise<[Element.Output], Element.Failure> {
        Element.combineAll(self)
    }
}

public protocol _PromiseCombineInterface {
    associatedtype Output
    associatedtype Failure: Error
    
    static func combineAll(_ promises: [Self]) -> Promise<[Output], Failure>
    static func mergeAll(_ promises: [Self]) -> Promise<Output, Failure>
}

extension Promise: _PromiseCombineInterface {
    public static func mergeAll(_ promises: [Promise<Output, Failure>]) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        
        for sub in promises {
            sub.subscribe(promise.fulfill, promise.reject)
        }
        
        return promise
    }
    
    public static func combineAll(_ promises: [Promise<Output, Failure>]) -> Promise<[Output], Failure> {
        if promises.isEmpty { return Promise<[Output], Failure>.resolve([]) }
        
        let lock = RecursiveLock()
        let promise = Promise<[Output], Failure>()
        
        let count = promises.count
        var outputs = [Output?](repeating: nil, count: count)
        var dp = [Bool](repeating: false, count: count)
        var fulfilled = 0
        var hasRejected = false
        var hasFulfilled = false
        
        for (i, child) in promises.enumerated() {
            child.subscribe({ output in
                lock.lock(); defer { lock.unlock() }
                
                if hasRejected || hasFulfilled { return }
                if dp[i] == false {
                    dp[i] = true
                    fulfilled += 1
                }
                outputs[i] = output
                if fulfilled == count {
                    hasFulfilled = true
                    promise.fulfill(outputs as! [Output])
                }
            }, { failure in
                lock.lock(); defer { lock.unlock() }
                
                if hasRejected || hasFulfilled { return }
                hasRejected = true
                promise.reject(failure)
            })
        }
        
        return promise
    }
    
}
