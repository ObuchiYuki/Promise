//
//  Promise+Combine.swift
//  
//
//  Created by yuki on 2021/10/24.
//

#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Promise {
    @inlinable public func publisher() -> some Publisher<Output, Failure> {
        Future{ handler in
            self.subscribe({ handler(.success($0)) }, { handler(.failure($0)) })
        }
    }
}

@available(OSX 10.15, iOS 13.0, *)
extension Publisher {
    @inlinable public func firstValue() -> Promise<Output?, Failure> {
        let promise = Promise<Output?, Failure>()

        var cancellable: AnyCancellable?
        cancellable = self.sink{ completion in
            switch completion {
            case .finished: promise.resolve(nil)
            case .failure(let error): promise.reject(error)
            }
            cancellable?.cancel()
        } receiveValue: { value in
            promise.resolve(value)
            cancellable?.cancel()
        }
       
        return promise
    }
}
#endif
