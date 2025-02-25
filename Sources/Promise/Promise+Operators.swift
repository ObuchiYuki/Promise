//
//  Promise+Operators.swift
//  
//
//  Created by yuki on 2021/10/24.
//

extension Promise {
    @inlinable
    public func map<T>(@_implicitSelfCapture _ tranceform: @escaping (Output) -> T) -> Promise<T, Failure> {
        let promise = Promise<T, Failure>()
        self.subscribe({ promise.resolve(tranceform($0)) }, promise.reject)
        return promise
    }
    
    @inlinable
    public func flatMap<T>(@_implicitSelfCapture _ tranceform: @escaping (Output) -> Promise<T, Failure>) -> Promise<T, Failure> {
        let promise = Promise<T, Failure>()
        self.subscribe({ tranceform($0).subscribe(promise.resolve, promise.reject) }, promise.reject)
        return promise
    }
    
    @inlinable
    public func flatMap<T>(@_implicitSelfCapture _ tranceform: @escaping (Output, @escaping (T) -> (), @escaping (Failure)->()) -> ()) -> Promise<T, Failure> {
        let promise = Promise<T, Failure>()
        self.subscribe({ tranceform($0, promise.resolve, promise.reject) }, promise.reject)
        return promise
    }
    
    @inlinable
    public func tryMap<T>(@_implicitSelfCapture _ tranceform: @escaping (Output) throws -> T) -> Promise<T, Error> {
        let promise = Promise<T, Error>()
        self.subscribe({ do { try promise.resolve(tranceform($0)) } catch { promise.reject(error) } }, promise.reject)
        return promise
    }
    
    @inlinable
    public func tryFlatMap<T>(@_implicitSelfCapture _ tranceform: @escaping (Output) throws -> Promise<T, Error>) -> Promise<T, Error> {
        let promise = Promise<T, Error>()
        self.subscribe({
            do { try tranceform($0).subscribe(promise.resolve, promise.reject) } catch { promise.reject(error) }
        }, promise.reject)
        return promise
    }
    
    @inlinable
    public func tryFlatMap<T>(@_implicitSelfCapture _ tranceform: @escaping (Output, @escaping (T) -> (), @escaping (Failure)->()) throws -> ()) -> Promise<T, Error> {
        let promise = Promise<T, Error>()
        self.subscribe({
            do { try tranceform($0, promise.resolve, promise.reject) } catch { promise.reject(error) }
        }, promise.reject)
        return promise
    }
    
    @inlinable
    public func mapError<T>(@_implicitSelfCapture _ tranceform: @escaping (Failure) -> T) -> Promise<Output, T> {
        let promise = Promise<Output, T>()
        self.subscribe(promise.resolve, { promise.reject(tranceform($0)) })
        return promise
    }
    
    @inlinable
    public func replaceError(@_implicitSelfCapture _ tranceform: @escaping (Failure) -> Output) -> Promise<Output, Never> {
        let promise = Promise<Output, Never>()
        self.subscribe(promise.resolve, { promise.resolve(tranceform($0)) })
        return promise
    }
    
    @inlinable
    public func replaceError(@_implicitSelfCapture with value: @autoclosure @escaping () -> Output) -> Promise<Output, Never> {
        let promise = Promise<Output, Never>()
        self.subscribe(promise.resolve, {_ in promise.resolve(value()) })
        return promise
    }
    
    @inlinable
    public func replaceErrorWithNil<T>() -> Promise<Output, Never> where Output == Optional<T> {
        let promise = Promise<Output, Never>()
        self.subscribe(promise.resolve, {_ in promise.resolve(nil) })
        return promise
    }
    
    @inlinable
    public func replaceErrorWithNil() -> Promise<Output?, Never> {
        let promise = Promise<Output?, Never>()
        self.subscribe(promise.resolve, {_ in promise.resolve(nil) })
        return promise
    }
        
    @inlinable
    public func tryReplaceError(@_implicitSelfCapture _ tranceform: @escaping (Failure) throws -> Output) -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        self.subscribe(promise.resolve, {
            do { try promise.resolve(tranceform($0)) } catch { promise.reject(error) }
        })
        return promise
    }
    
    @inlinable
    public func eraseToError() -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        self.subscribe(promise.resolve, promise.reject)
        return promise
    }
    
    @inlinable
    public func eraseToVoid() -> Promise<Void, Failure> {
        let promise = Promise<Void, Failure>()
        self.subscribe({_ in promise.resolve(()) }, promise.reject)
        return promise
    }
    
    @inlinable
    public func packToResult() -> Promise<Result<Output, Failure>, Never> {
        let promise = Promise<Result<Output, Failure>, Never>()
        self.subscribe({ promise.resolve(.success($0)) }, { promise.resolve(.failure($0)) })
        return promise
    }
    
    @inlinable
    public func unpackResult<O>() -> Promise<O, Failure> where Output == Result<O, Failure> {
        let promise = Promise<O, Failure>()
        self.subscribe({
            switch $0 {
            case .success(let output): promise.resolve(output)
            case .failure(let failure): promise.reject(failure)
            }
        }, promise.reject)
        return promise
    }
    
    @inlinable
    public func unpackResult<O, F>() -> Promise<O, F> where Output == Result<O, F>, Failure == Never {
        let promise = Promise<O, F>()
        self.subscribe({
            switch $0 {
            case .success(let output): promise.resolve(output)
            case .failure(let failure): promise.reject(failure)
            }
        }, {_ in})
        return promise
    }
    
    @inlinable
    public func peek(@_implicitSelfCapture _ receiveOutput: @escaping (Output) -> ()) -> Promise<Output, Failure> {
        self.subscribe(receiveOutput, {_ in})
        return self
    }
    
    @inlinable
    public func peekError(@_implicitSelfCapture _ receiveFailure: @escaping (Failure) -> ()) -> Promise<Output, Failure> {
        self.subscribe({_ in}, receiveFailure)
        return self
    }
    
    @inlinable
    public func tryPeek(@_implicitSelfCapture _ receiveOutput: @escaping (Output) throws -> ()) -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        self.subscribe({ output in
            do { try receiveOutput(output); promise.resolve(output) } catch { promise.reject(error) }
        }, promise.reject)
        return promise
    }
    
    @inlinable
    public func flatPeek<T>(@_implicitSelfCapture _ tranceform: @escaping (Output) -> Promise<T, Failure>) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        self.subscribe({ output in tranceform(output).subscribe({_ in promise.resolve(output) }, promise.reject) }, promise.reject)
        return promise
    }

    @inlinable
    public func tryFlatPeek<T>(@_implicitSelfCapture _ tranceform: @escaping (Output) throws -> Promise<T, Failure>) -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        self.subscribe({ output in
            do { try tranceform(output).subscribe({_ in promise.resolve(output) }, promise.reject) } catch { promise.reject(error) }
        }, promise.reject)
        return promise
    }
    
    @discardableResult
    @inlinable
    public func `catch`(@_implicitSelfCapture _ receiveFailure: @escaping (Failure) -> ()) -> Promise<Void, Never> {
        let promise = Promise<Void, Never>()
        self.subscribe({_ in promise.resolve(()) }, { receiveFailure($0); promise.resolve(()) })
        return promise
    }

    @inlinable
    public func `catch`<ErrorType: Error>(_ errorType: ErrorType.Type, @_implicitSelfCapture _ receiveFailure: @escaping (ErrorType) -> ()) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        self.subscribe(promise.resolve, { failure in
            if let error = failure as? ErrorType { receiveFailure(error) }
            promise.reject(failure)
        })
        return promise
    }
    
    @inlinable
    public func tryCatch(@_implicitSelfCapture _ receiveFailure: @escaping (Failure) throws -> ()) -> Promise<Void, Error> {
        let promise = Promise<Void, Error>()
        self.subscribe({_ in promise.resolve(()) }, { failure in
            do { try receiveFailure(failure); promise.resolve(()) } catch { promise.reject(error) }
        })
        return promise
    }
    
    @inlinable
    public func tryCatch<ErrorType: Error>(_ errorType: ErrorType.Type, @_implicitSelfCapture _ receiveFailure: @escaping (ErrorType) throws -> ()) -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        self.subscribe(promise.resolve, { failure in
            if let error = failure as? ErrorType {
                do { try receiveFailure(error) } catch { promise.reject(error) }
            }
            promise.reject(failure)
        })
        return promise
    }
    
    @inlinable
    public func integrateError() -> Promise<Void, Error> where Output == Optional<Error> {
        let promise = Promise<Void, Error>()
        self.subscribe({ if let error = $0 { promise.reject(error) } else { promise.resolve(()) } }, promise.reject)
        return promise
    }
    
    @discardableResult
    @inlinable
    public func finally(@_implicitSelfCapture _ receive: @escaping () -> ()) -> Promise<Output, Failure> {
        self.subscribe({_ in receive() }, {_ in receive() })
        return self
    }
    
    @inlinable
    public func tryFinally(@_implicitSelfCapture _ receive: @escaping () throws -> ()) -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        self.subscribe({ output in
            do { try receive(); promise.resolve(output) } catch { promise.reject(error) }
        }, { failure in
            do { try receive(); promise.reject(failure) } catch { promise.reject(error) }
        })
        return promise
    }
    
    @inlinable
    public func sink(@_implicitSelfCapture _ receiveOutput: @escaping (Output) -> (), @_implicitSelfCapture _ receiveFailure: @escaping (Failure) -> ()) {
        self.subscribe(receiveOutput, receiveFailure)
    }
    
    @inlinable
    public func sink(@_implicitSelfCapture _ receiveOutput: @escaping (Output) -> ()) where Failure == Never {
        self.subscribe(receiveOutput, {_ in })
    }
    
    @inlinable
    public func resolve() where Output == Void {
        self.resolve(())
    }
    
    @inlinable
    public func resolve(_ output: () -> Output) where Failure == Never {
        self.resolve(output())
    }
    
    @inlinable
    public func resolve(_ output: () throws -> Output) where Failure == Error {
        do {
            self.resolve(try output())
        } catch {
            self.reject(error)
        }
    }
}
