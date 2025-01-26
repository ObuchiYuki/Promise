//
//  Promise+Combination.swift
//
//
//  Created by yuki on 2021/08/12.
//

extension Promise {
    @inlinable public func merge(_ a: Promise<Output, Failure>) -> Promise<Output, Failure> {
        Promise.merge(self, a)
    }
    
    @inlinable public func merge(_ a: Promise<Output, Failure>, _ b: Promise<Output, Failure>) -> Promise<Output, Failure> {
        Promise.merge(self, a, b)
    }
    
    @inlinable public func merge(_ a: Promise<Output, Failure>, _ b: Promise<Output, Failure>, _ c: Promise<Output, Failure>) -> Promise<Output, Failure> {
        Promise.merge(self, a, b, c)
    }
    
    @inlinable public static func merge(_ a: Promise<Output, Failure>, _ b: Promise<Output, Failure>) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        a.subscribe(promise.resolve, promise.reject)
        b.subscribe(promise.resolve, promise.reject)
        return promise
    }
    
    @inlinable public static func merge(_ a: Promise<Output, Failure>, _ b: Promise<Output, Failure>, _ c: Promise<Output, Failure>) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        a.subscribe(promise.resolve, promise.reject)
        b.subscribe(promise.resolve, promise.reject)
        c.subscribe(promise.resolve, promise.reject)
        return promise
    }
    
    @inlinable public static func merge(_ a: Promise<Output, Failure>, _ b: Promise<Output, Failure>, _ c: Promise<Output, Failure>, _ d: Promise<Output, Failure>) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        a.subscribe(promise.resolve, promise.reject)
        b.subscribe(promise.resolve, promise.reject)
        c.subscribe(promise.resolve, promise.reject)
        d.subscribe(promise.resolve, promise.reject)
        return promise
    }
}

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
    
    @inlinable public static func combine<A, B>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>) -> Promise<(A, B), Failure> {
        let promise = Promise<(A, B), Failure>()
        
        var outputA: A?, outputB: B?
        @inline(__always) func check() {
            guard let outputA = outputA, let outputB = outputB else { return }
            promise.resolve((outputA, outputB))
        }
        a.subscribe({ outputA = $0; check() }, promise.reject)
        b.subscribe({ outputB = $0; check() }, promise.reject)
        
        return promise
    }
    
    @inlinable public static func combine<A, B, C>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>, _ c: Promise<C, Failure>) -> Promise<(A, B, C), Failure> {
        let promise = Promise<(A, B, C), Failure>()
        
        var outputA: A?, outputB: B?, outputC: C?
        @inline(__always) func check() {
            guard let outputA = outputA, let outputB = outputB, let outputC = outputC else { return }
            promise.resolve((outputA, outputB, outputC))
        }
        a.subscribe({ outputA = $0; check() }, promise.reject)
        b.subscribe({ outputB = $0; check() }, promise.reject)
        c.subscribe({ outputC = $0; check() }, promise.reject)
        
        return promise
    }
    
    @inlinable public static func combine<A, B, C, D>(_ a: Promise<A, Failure>, _ b: Promise<B, Failure>, _ c: Promise<C, Failure>, _ d: Promise<D, Failure>) -> Promise<(A, B, C, D), Failure> {
        let promise = Promise<(A, B, C, D), Failure>()
        
        var outputA: A?, outputB: B?, outputC: C?, outputD: D?
        @inline(__always) func check() {
            guard let outputA = outputA, let outputB = outputB, let outputC = outputC, let outputD = outputD else { return }
            promise.resolve((outputA, outputB, outputC, outputD))
        }
        a.subscribe({ outputA = $0; check() }, promise.reject)
        b.subscribe({ outputB = $0; check() }, promise.reject)
        c.subscribe({ outputC = $0; check() }, promise.reject)
        d.subscribe({ outputD = $0; check() }, promise.reject)
        
        return promise
    }
}

extension Array {
    @inlinable public func mergeAll<Output, Failure: Error>() -> Promise<Output, Failure> where Self.Element == Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        
        for sub in self {
            sub.subscribe(promise.resolve, promise.reject)
        }
        
        return promise
    }
    
    @inlinable public func combineAll<Output, Failure: Error>() -> Promise<[Output], Failure> where Self.Element == Promise<Output, Failure> {
        if self.isEmpty { return .resolve([]) }
        
        let lock = Lock()
        let promise = Promise<[Output], Failure>()
        
        let count = self.count
        var outputs = [Output?](repeating: nil, count: count)
        var fulfilled = 0
        var hasCompleted = false
        
        for (i, child) in self.enumerated() {
            child.subscribe({ output in
                lock.lock()
                defer { lock.unlock() }
                
                if hasCompleted { return }
                
                if outputs[i] == nil { fulfilled += 1 }
                outputs[i] = output
                
                if fulfilled == count {
                    hasCompleted = true
                    promise.resolve(outputs as! [Output])
                }
            }, { failure in
                lock.lock()
                defer { lock.unlock() }
                
                if hasCompleted { return }
                hasCompleted = true
                promise.reject(failure)
            })
        }
        
        return promise
    }

    @inlinable public func combineAll<Failure: Error>() -> Promise<Void, Failure> where Self.Element == Promise<Void, Failure> {
        if self.isEmpty { return .resolve() }
        
        let lock = Lock()
        let promise = Promise<Void, Failure>()
        
        let count = self.count
        var received = [Bool](repeating: false, count: count)
        var fulfilled = 0
        var hasCompleted = false
        
        for (i, child) in self.enumerated() {
            child.subscribe({ output in
                lock.lock()
                defer { lock.unlock() }
                
                if hasCompleted { return }
                if received[i] == false {
                    received[i] = true
                    fulfilled += 1
                }
                if fulfilled == count {
                    hasCompleted = true
                    promise.resolve()
                }
            }, { failure in
                lock.lock()
                defer { lock.unlock() }
                
                if hasCompleted { return }
                hasCompleted = true
                promise.reject(failure)
            })
        }
        
        return promise
    }
}
