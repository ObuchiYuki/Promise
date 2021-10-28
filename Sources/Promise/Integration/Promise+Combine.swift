//
//  Promise+Combine.swift
//  
//
//  Created by yuki on 2021/10/24.
//

import Combine

@available(OSX 10.15, *)
extension Promise {
    public func publisher() -> Publisher {
        Publisher(self)
    }
    
    public final class Publisher: Combine.Publisher {
        init(_ promise: Promise<Output, Failure>) {
            self.future = Future{ handler in
                promise.sink({ output in
                    handler(.success(output))
                }, { failure in
                    handler(.failure(failure))
                })
            }
        }
        
        let future: Future<Output, Failure>
        
        public func receive<Downstream: Combine.Subscriber>(subscriber: Downstream) where Downstream.Failure == Failure, Downstream.Input == Output {
            future.receive(subscriber: subscriber)
        }
    }
}
