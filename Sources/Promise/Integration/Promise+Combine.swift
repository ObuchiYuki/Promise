//
//  Promise+Combine.swift
//  
//
//  Created by yuki on 2021/10/24.
//

import Combine

@available(OSX 10.15, *)
extension Promise {

    @inlinable public func publisher() -> Publisher {
        Publisher(self)
    }
    
    public final class Publisher: Combine.Publisher {
        @inlinable init(_ promise: Promise<Output, Failure>) {
            self.future = Future{ handler in
                promise.sink({ output in
                    handler(.success(output))
                }, { failure in
                    handler(.failure(failure))
                })
            }
        }
        
        @usableFromInline let future: Future<Output, Failure>
        
        @inlinable public func receive<Downstream: Combine.Subscriber>(subscriber: Downstream) where Downstream.Failure == Failure, Downstream.Input == Output {
            future.receive(subscriber: subscriber)
        }
    }
}
