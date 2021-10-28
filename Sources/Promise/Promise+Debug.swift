//
//  Promise+Debug.swift
//  CoreUtil
//
//  Created by yuki on 2021/08/23.
//  Copyright © 2021 yuki. All rights reserved.
//

import Foundation

extension Promise {
    public func breakpoint(_ receiveOutput: ((Output) -> Bool)? = nil, _ receiveFailure: ((Failure) -> Bool)? = nil) -> Promise<Output, Failure> {
        self.subscribe({ output in
            if receiveOutput?(output) == true { raise(SIGTRAP) }
        }, { failure in
            if receiveFailure?(failure) == true { raise(SIGTRAP) }
        })
        return self
    }
    
    public func breakpointOnError() -> Promise<Output, Failure> {
        self.breakpoint(nil, {_ in true })
    }
    
    public func assertNoFailure(_ prefix: String = "", file: StaticString = #file, line: UInt = #line) -> Promise<Output, Never> {
        Promise<Output, Never> { resolve, _ in
            self.subscribe(resolve, { error in
                let prefix = prefix.isEmpty ? "" : prefix + ": "
                fatalError("\(prefix)\(error)", file: file, line: line)
            })
        }
    }
    
    final private class PrintTarget: TextOutputStream {
        var stream: TextOutputStream
        func write(_ string: String) { stream.write(string) }
        init(stream: TextOutputStream) { self.stream = stream }
    }
    
    public func print(_ prefix: String = "", to stream: TextOutputStream? = nil) -> Promise<Output, Failure> {
        let prefix = prefix.isEmpty ? "" : "\(prefix): "
        let stream = stream.map(PrintTarget.init)
        
        func log(_ text: String) {
            if var stream = stream { Swift.print(text, to: &stream) } else { Swift.print(text) }
        }
        
        self.subscribe({ output in
            log("\(prefix)receive output: (\(output))")
        }, { failure in
            log("\(prefix)receive failure: (\(failure))")
        })
        
        return self
    }
    
    public func measureTimeInterval(_ prefix: String = "", to stream: TextOutputStream? = nil) -> Promise<Output, Failure> {
        let prefix = prefix.isEmpty ? "" : "\(prefix): "
        let stream = stream.map(PrintTarget.init)
        let startDate = Date()
        
        func log(_ text: String) {
            if var stream = stream { Swift.print(text, to: &stream) } else { Swift.print(text) }
        }
        
        self.subscribe({ output in
            let timeInterval = Date().timeIntervalSince(startDate)
            log("\(prefix)receive output: [\(timeInterval)s] (\(output))")
        }, { failure in
            let timeInterval = Date().timeIntervalSince(startDate)
            log("\(prefix)receive failure: [\(timeInterval)s] (\(failure))")
        })
        
        return self
    }
}
