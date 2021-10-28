//
//  Promise+Operators.swift
//  
//
//  Created by yuki on 2021/10/24.
//

extension Promise {
    @inlinable public func map<T>(_ tranceform: @escaping (Output) -> T) -> Promise<T, Failure> {
        Promise<T, Failure> { resolve, reject in
            self.subscribe({ resolve(tranceform($0)) }, reject)
        }
    }
    
    @inlinable public func flatMap<T>(_ tranceform: @escaping (Output) -> Promise<T, Failure>) -> Promise<T, Failure> {
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
    
    @inlinable public func mapError<T>(_ tranceform: @escaping (Failure) -> T) -> Promise<Output, T> {
        Promise<Output, T> { resolve, reject in
            self.subscribe(resolve, { reject(tranceform($0)) })
        }
    }
        
    @inlinable public func replaceError(with value: @autoclosure @escaping () -> Output) -> Promise<Output, Never> {
        Promise<Output, Never> { resolve, _ in
            self.subscribe(resolve, {_ in resolve(value()) })
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
    
    @inlinable public func peek(_ receiveOutput: @escaping (Output) -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe({ receiveOutput($0); resolve($0) }, reject)
        }
    }
    
    @inlinable public func peekError(_ receiveFailure: @escaping (Failure) -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe(resolve, { receiveFailure($0); reject($0) })
        }
    }
    
    @discardableResult
    @inlinable public func `catch`(_ receiveFailure: @escaping (Failure) -> ()) -> Promise<Void, Never> {
        Promise<Void, Never> { resolve, _ in
            self.subscribe({_ in resolve(()) }, { receiveFailure($0); resolve(()) })
        }
    }
    
    @discardableResult
    @inlinable public func finally(_ receive: @escaping () -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe({ resolve($0); receive() }, { reject($0); receive() })
        }
    }
    
    @inlinable public func sink(_ receiveOutput: @escaping (Output) -> (), _ receiveFailure: @escaping (Failure) -> ()) {
        self.subscribe(receiveOutput, receiveFailure)
    }
    
    @inlinable public func sink(_ receiveOutput: @escaping (Output) -> ()) where Failure == Never {
        self.subscribe(receiveOutput, {_ in})
    }
}
