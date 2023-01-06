//
//  Promise+Operators.swift
//  
//
//  Created by yuki on 2021/10/24.
//

extension Promise {
    public func map<T>(_ tranceform: @escaping (Output) -> T) -> Promise<T, Failure> {
        Promise<T, Failure> { resolve, reject in
            self.subscribe({ resolve(tranceform($0)) }, reject)
        }
    }
    
    public func flatMap<T>(_ tranceform: @escaping (Output) -> Promise<T, Failure>) -> Promise<T, Failure> {
        Promise<T, Failure> { resolve, reject in
            self.subscribe({ tranceform($0).subscribe(resolve, reject) }, reject)
        }
    }
    
    public func tryMap<T>(_ tranceform: @escaping (Output) throws -> T) -> Promise<T, Error> {
        Promise<T, Error> { resolve, reject in
            self.subscribe({ do { try resolve(tranceform($0)) } catch { reject(error) } }, reject)
        }
    }
    
    public func tryFlatMap<T>(_ tranceform: @escaping (Output) throws -> Promise<T, Error>) -> Promise<T, Error> {
        Promise<T, Error> { resolve, reject in
            self.subscribe({ do { try tranceform($0).subscribe(resolve, reject) } catch { reject(error) } }, reject)
        }
    }
    
    public func mapError<T>(_ tranceform: @escaping (Failure) -> T) -> Promise<Output, T> {
        Promise<Output, T> { resolve, reject in
            self.subscribe(resolve, { reject(tranceform($0)) })
        }
    }
    
    public func replaceError(_ tranceform: @escaping (Failure) -> Output) -> Promise<Output, Never> {
        Promise<Output, Never> { resolve, _ in
            self.subscribe(resolve, { resolve(tranceform($0)) })
        }
    }
    
    public func replaceError(with value: @autoclosure @escaping () -> Output) -> Promise<Output, Never> {
        Promise<Output, Never> { resolve, _ in
            self.subscribe(resolve, {_ in resolve(value()) })
        }
    }
    
    public func replaceError<ErrorType: Error>(_ errorType: ErrorType.Type, _ tranceform: @escaping (ErrorType) -> Output) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe(resolve, {
                if let e = $0 as? ErrorType { resolve(tranceform(e)) }
                reject($0)
            })
        }
    }
    
    public func tryReplaceError(_ tranceform: @escaping (Failure) throws -> Output) -> Promise<Output, Error> {
        Promise<Output, Error> { resolve, reject in
            self.subscribe(resolve, {
                do { try resolve(tranceform($0)) } catch { reject(error) }
            })
        }
    }
    
    public func tryReplaceError<ErrorType: Error>(_ errorType: ErrorType.Type, _ tranceform: @escaping (ErrorType) throws -> Output) -> Promise<Output, Error> {
        Promise<Output, Error> { resolve, reject in
            self.subscribe(resolve, {
                if let e = $0 as? ErrorType { do { try resolve(tranceform(e)) } catch { reject(error) } }
                reject($0)
            })
        }
    }
    
    public func eraseToError() -> Promise<Output, Error> {
        Promise<Output, Error> { resolve, reject in
            self.subscribe(resolve, reject)
        }
    }
    
    public func eraseToVoid() -> Promise<Void, Failure> {
        Promise<Void, Failure> { resolve, reject in
            self.subscribe({_ in resolve(()) }, reject)
        }
    }
    
    public func packToResult() -> Promise<Result<Output, Failure>, Never> {
        Promise<Result<Output, Failure>, Never>{ resolve, reject in
            self.subscribe({ resolve(.success($0)) }, { resolve(.failure($0)) })
        }
    }
    
    public func receive(on callback: @escaping (@escaping () -> ()) -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe({ o in callback{ resolve(o) } }, { f in callback{ reject(f) } })
        }
    }
    
    public func peek(_ receiveOutput: @escaping (Output) -> ()) -> Promise<Output, Failure> {
        self.subscribe(receiveOutput, {_ in})
        return self
    }
    
    public func peekError(_ receiveFailure: @escaping (Failure) -> ()) -> Promise<Output, Failure> {
        self.subscribe({_ in}, receiveFailure)
        return self
    }
    
    public func tryPeek(_ receiveOutput: @escaping (Output) throws -> ()) -> Promise<Output, Error> {
        Promise<Output, Error> { resolve, reject in
            self.sink({ output in
                do { try receiveOutput(output); resolve(output) } catch { reject(error) }
            }, reject)
        }
    }
    
    public func flatPeek<T>(_ tranceform: @escaping (Output) -> Promise<T, Failure>) -> Promise<Output, Failure> {
        Promise{ resolve, reject in
            self.sink({ output in tranceform(output).sink({_ in resolve(output) }, reject) }, reject)
        }
    }
    
    @discardableResult
    public func `catch`(_ receiveFailure: @escaping (Failure) -> ()) -> Promise<Void, Never> {
        Promise<Void, Never> { resolve, _ in
            self.subscribe({_ in resolve(()) }, { receiveFailure($0); resolve(()) })
        }
    }

    public func `catch`<ErrorType: Error>(_ errorType: ErrorType.Type, _ receiveFailure: @escaping (ErrorType) -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe(resolve, { failure in
                if let error = failure as? ErrorType { receiveFailure(error) }
                reject(failure)
            })
        }
    }
    
    @discardableResult
    public func finally(_ receive: @escaping () -> ()) -> Promise<Output, Failure> {
        self.subscribe({_ in receive() }, {_ in receive() })
        return self
    }
    
    public func sink(_ receiveOutput: @escaping (Output) -> (), _ receiveFailure: @escaping (Failure) -> ()) {
        self.subscribe(receiveOutput, receiveFailure)
    }
    
    public func sink(_ receiveOutput: @escaping (Output) -> ()) where Failure == Never {
        self.subscribe(receiveOutput, {_ in})
    }
}
