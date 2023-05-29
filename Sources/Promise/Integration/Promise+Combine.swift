//
//  Promise+Combine.swift
//  
//
//  Created by yuki on 2021/10/24.
//

#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, *)
extension Promise {
    public func publisher() -> Publisher {
        Publisher(self)
    }
    
    public final class Publisher: Combine.Publisher {
        init(_ promise: Promise<Output, Failure>) {
            self.future = Future{ handler in
                promise.subscribe({ handler(.success($0)) }, { handler(.failure($0)) })
            }
        }
        
        let future: Future<Output, Failure>
        
        public func receive<S: Combine.Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            future.receive(subscriber: subscriber)
        }
    }
}

#if canImport(Foundation)
import Foundation

@available(OSX 10.15, iOS 13.0, *)
extension Publisher {
    public func firstOutput() -> Promise<Output?, Failure> {
        let promise = Promise<Output?, Failure>()
        var cancellable: AnyCancellable? = nil
        var timer: Timer? = nil
        
        func clean() {
            cancellable?.cancel(); cancellable = nil
            timer?.invalidate(); timer = nil
        }
        
        cancellable = self.sink(receiveCompletion: { completion in
            guard case .pending = promise.state else { return }
            
            switch completion {
            case .finished: promise.fulfill(nil)
            case .failure(let error): promise.reject(error)
            }
            clean()
        }, receiveValue: { value in
            guard case .pending = promise.state else { return }
            promise.fulfill(value)
            clean()
        })
                
        return promise
    }
}

#endif
#endif
