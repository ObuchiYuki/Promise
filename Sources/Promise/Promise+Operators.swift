//
//  Promise+Operators.swift
//  
//
//  Created by yuki on 2021/10/24.
//

extension Promise {
    @inlinable public func map<T>(_ tranceform: @escaping (Output)->T) -> Promise<T, Failure> {
        Promise<T, Failure> { resolve, reject in
            self.subscribe({ resolve(tranceform($0)) }, reject)
        }
    }
    
    @inlinable public func flatMap<T>(_ tranceform: @escaping (Output)->Promise<T, Failure>) -> Promise<T, Failure> {
        Promise<T, Failure> { resolve, reject in
            self.subscribe({ tranceform($0).subscribe(resolve, reject) }, reject)
        }
    }
    
    @inlinable public func tryMap<T>(_ tranceform: @escaping (Output) throws -> T) -> Promise<T, Error> {
        Promise<T, Error> { resolve, reject in
            self.subscribe({ do { try resolve(tranceform($0)) } catch { reject(error) } }, reject)
        }
    }
    
    @inlinable public func tryFlatMap<T>(_ tranceform: @escaping (Output) throws -> Promise<T, Error>) -> Promise<T, Error> {
        Promise<T, Error> { resolve, reject in
            self.subscribe({ do { try tranceform($0).subscribe(resolve, reject) } catch { reject(error) } }, reject)
        }
    }
    
    @inlinable public func mapError<T>(_ tranceform: @escaping (Failure)->T) -> Promise<Output, T> {
        Promise<Output, T> { resolve, reject in
            self.subscribe(resolve, { reject(tranceform($0)) })
        }
    }
        
    @inlinable public func replaceError(with value: Output) -> Promise<Output, Never> {
        Promise<Output, Never> { resolve, _ in
            self.subscribe(resolve, {_ in resolve(value) })
        }
    }
    
    @inlinable public func eraseToError() -> Promise<Output, Error> {
        Promise<Output, Error> { resolve, reject in
            self.subscribe(resolve, reject)
        }
    }
    
    @inlinable public func eraseToVoid() -> Promise<Void, Failure> {
        Promise<Void, Failure> { resolve, reject in
            self.subscribe({_ in resolve(()) }, reject)
        }
    }
    
    @inlinable public func receive(on callback: @escaping (@escaping () -> ()) -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe({ o in callback{ resolve(o) } }, { f in callback{ reject(f) } })
        }
    }
    
    @inlinable public func peek(_ onFulfilled: @escaping (Output) -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe({ onFulfilled($0); resolve($0) }, reject)
        }
    }
    
    @inlinable public func peekError(_ onRejected: @escaping (Failure) -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe(resolve, { onRejected($0); reject($0) })
        }
    }
    
    @discardableResult
    @inlinable public func `catch`(_ onRejected: @escaping (Failure) -> ()) -> Promise<Void, Never> {
        Promise<Void, Never> { resolve, _ in
            self.subscribe({_ in resolve(()) }, { onRejected($0); resolve(()) })
        }
    }
    
    @discardableResult
    @inlinable public func finally(_ onFinally: @escaping () -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe({ onFinally(); resolve($0) }, { onFinally(); reject($0) })
        }
    }
    
    @inlinable public func sink(_ onFulfilled: @escaping (Output) -> (), _ onRejected: @escaping (Failure) -> ()) {
        self.subscribe(onFulfilled, onRejected)
    }
    
    @inlinable public func sink(_ onFulfilled: @escaping (Output) -> ()) where Failure == Never {
        self.subscribe(onFulfilled, {_ in})
    }
}
