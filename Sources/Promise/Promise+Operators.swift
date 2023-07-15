//
//  Promise+Operators.swift
//  
//
//  Created by yuki on 2021/10/24.
//

extension Promise {
    @inlinable public func map<T>(_ tranceform: @escaping (Output) -> T) -> Promise<T, Failure> {
        let promise = Promise<T, Failure>()
        self.subscribe({ promise.resolve(tranceform($0)) }, promise.reject)
        return promise
    }
    
    @inlinable public func flatMap<T>(_ tranceform: @escaping (Output) -> Promise<T, Failure>) -> Promise<T, Failure> {
        let promise = Promise<T, Failure>()
        self.subscribe({ tranceform($0).subscribe(promise.resolve, promise.reject) }, promise.reject)
        return promise
    }
    
    @inlinable public func flatMap<T>(_ tranceform: @escaping (Output, @escaping (T) -> (), @escaping (Failure)->()) -> ()) -> Promise<T, Failure> {
        let promise = Promise<T, Failure>()
        self.subscribe({ tranceform($0, promise.resolve, promise.reject) }, promise.reject)
        return promise
    }
    
    @inlinable public func tryMap<T>(_ tranceform: @escaping (Output) throws -> T) -> Promise<T, Error> {
        let promise = Promise<T, Error>()
        self.subscribe({ do { try promise.resolve(tranceform($0)) } catch { promise.reject(error) } }, promise.reject)
        return promise
    }
    
    @inlinable public func tryFlatMap<T>(_ tranceform: @escaping (Output) throws -> Promise<T, Error>) -> Promise<T, Error> {
        let promise = Promise<T, Error>()
        self.subscribe({
            do { try tranceform($0).subscribe(promise.resolve, promise.reject) } catch { promise.reject(error) }
        }, promise.reject)
        return promise
    }
    
    @inlinable public func tryFlatMap<T>(_ tranceform: @escaping (Output, @escaping (T) -> (), @escaping (Failure)->()) throws -> ()) -> Promise<T, Error> {
        let promise = Promise<T, Error>()
        self.subscribe({
            do { try tranceform($0, promise.resolve, promise.reject) } catch { promise.reject(error) }
        }, promise.reject)
        return promise
    }
    
    @inlinable public func mapError<T>(_ tranceform: @escaping (Failure) -> T) -> Promise<Output, T> {
        let promise = Promise<Output, T>()
        self.subscribe(promise.resolve, { promise.reject(tranceform($0)) })
        return promise
    }
    
    @inlinable public func replaceError(_ tranceform: @escaping (Failure) -> Output) -> Promise<Output, Never> {
        let promise = Promise<Output, Never>()
        self.subscribe(promise.resolve, { promise.resolve(tranceform($0)) })
        return promise
    }
    
    @inlinable public func replaceError(with value: @autoclosure @escaping () -> Output) -> Promise<Output, Never> {
        let promise = Promise<Output, Never>()
        self.subscribe(promise.resolve, {_ in promise.resolve(value()) })
        return promise
    }
        
    @inlinable public func tryReplaceError(_ tranceform: @escaping (Failure) throws -> Output) -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        self.subscribe(promise.resolve, {
            do { try promise.resolve(tranceform($0)) } catch { promise.reject(error) }
        })
        return promise
    }
    
    @inlinable public func eraseToError() -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        self.subscribe(promise.resolve, promise.reject)
        return promise
    }
    
    @inlinable public func eraseToVoid() -> Promise<Void, Failure> {
        let promise = Promise<Void, Failure>()
        self.subscribe({_ in promise.resolve(()) }, promise.reject)
        return promise
    }
    
    @inlinable public func packToResult() -> Promise<Result<Output, Failure>, Never> {
        let promise = Promise<Result<Output, Failure>, Never>()
        self.subscribe({ promise.resolve(.success($0)) }, { promise.resolve(.failure($0)) })
        return promise
    }

    @inlinable public func receive(on callback: @escaping (@escaping () -> ()) -> ()) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        self.subscribe({ o in callback{ promise.resolve(o) } }, { f in callback{ promise.reject(f) } })
        return promise
    }
    
    @inlinable public func peek(_ receiveOutput: @escaping (Output) -> ()) -> Promise<Output, Failure> {
        self.subscribe(receiveOutput, {_ in})
        return self
    }
    
    @inlinable public func peekError(_ receiveFailure: @escaping (Failure) -> ()) -> Promise<Output, Failure> {
        self.subscribe({_ in}, receiveFailure)
        return self
    }
    
    @inlinable public func tryPeek(_ receiveOutput: @escaping (Output) throws -> ()) -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        self.subscribe({ output in
            do { try receiveOutput(output); promise.resolve(output) } catch { promise.reject(error) }
        }, promise.reject)
        return promise
    }
    
    @inlinable public func flatPeek<T>(_ tranceform: @escaping (Output) -> Promise<T, Failure>) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        self.subscribe({ output in tranceform(output).subscribe({_ in promise.resolve(output) }, promise.reject) }, promise.reject)
        return promise
    }

    @inlinable public func tryFlatPeek<T>(_ tranceform: @escaping (Output) throws -> Promise<T, Failure>) -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        self.subscribe({ output in
            do { try tranceform(output).subscribe({_ in promise.resolve(output) }, promise.reject) } catch { promise.reject(error) }
        }, promise.reject)
        return promise
    }
    
    @discardableResult
    @inlinable public func `catch`(_ receiveFailure: @escaping (Failure) -> ()) -> Promise<Void, Never> {
        let promise = Promise<Void, Never>()
        self.subscribe({_ in promise.resolve(()) }, { receiveFailure($0); promise.resolve(()) })
        return promise
    }
    
    @discardableResult
    @inlinable public func tryCatch(_ receiveFailure: @escaping (Failure) throws -> ()) -> Promise<Void, Error> {
        let promise = Promise<Void, Error>()
        self.subscribe({_ in promise.resolve(()) }, { failure in
            do { try receiveFailure(failure); promise.resolve(()) } catch { promise.reject(error) }
        })
        return promise
    
    }

    @inlinable public func `catch`<ErrorType: Error>(_ errorType: ErrorType.Type, _ receiveFailure: @escaping (ErrorType) -> ()) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        self.subscribe(promise.resolve, { failure in
            if let error = failure as? ErrorType { receiveFailure(error) }
            promise.reject(failure)
        })
        return promise
    }
    
    @inlinable public func integrateError() -> Promise<Void, Error> where Output == Optional<Error> {
        let promise = Promise<Void, Error>()
        self.subscribe({ if let error = $0 { promise.reject(error) } else { promise.resolve(()) } }, promise.reject)
        return promise
    }
    
    @discardableResult
    @inlinable public func finally(_ receive: @escaping () -> ()) -> Promise<Output, Failure> {
        self.subscribe({_ in receive() }, {_ in receive() })
        return self
    }
    
    @inlinable public func sink(_ receiveOutput: @escaping (Output) -> (), _ receiveFailure: @escaping (Failure) -> ()) {
        self.subscribe(receiveOutput, receiveFailure)
    }
    
    @inlinable public func sink(_ receiveOutput: @escaping (Output) -> ()) where Failure == Never {
        self.subscribe(receiveOutput, {_ in})
    }
    
    @inlinable public func resolve() where Output == Void {
        self.resolve(())
    }
}
