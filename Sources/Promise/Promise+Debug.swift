//
//  Promise+Debug.swift
//
//
//  Created by yuki on 2021/08/23.
//

extension Promise {
    public func assertNoFailure(_ prefix: String = "", file: StaticString = #file, line: UInt = #line) -> Promise<Output, Never> {
        Promise<Output, Never> { resolve, _ in
            self.subscribe(resolve, { error in
                let prefix = prefix.isEmpty ? "" : prefix + ": "
                fatalError("\(prefix)\(error)", file: file, line: line)
            })
        }
    }
    
    private struct PrintTarget: TextOutputStream {
        func write(_ string: String) { Swift.print(string) }
    }
    
    public func print(_ prefix: String = "") -> Promise<Output, Failure> {
        var target = PrintTarget()
        return self.print(prefix, to: &target)
    }
    
    public func print<Target: TextOutputStream>(_ prefix: String = "", to target: inout Target) -> Promise<Output, Failure> {
        var target = target
        let prefix = prefix.isEmpty ? "" : "\(prefix): "
        
        self.subscribe({ output in
            target.write("\(prefix)receive output: (\(output))")
        }, { failure in
            target.write("\(prefix)receive failure: (\(failure))")
        })
        
        return self
    }
}

#if canImport(CoreFoundation)
import CoreFoundation

extension Promise {
    public func breakpoint(_ receiveOutput: ((Output) -> Bool)? = nil, _ receiveFailure: ((Failure) -> Bool)? = nil) -> Promise<Output, Failure> {
        self.subscribe({ output in
            if receiveOutput?(output) == true { raise(SIGTRAP) }
        }, { failure in
            if receiveFailure?(failure) == true { raise(SIGTRAP) }
        })
        return self
    }

    public func breakpointOnError(_ prefix: String = "") -> Promise<Output, Failure> {
        var target = PrintTarget()
        return self.breakpointOnError(prefix, to: &target)
    }
    
    public func breakpointOnError<Target: TextOutputStream>(_ prefix: String = "", to target: inout Target) -> Promise<Output, Failure> {
        var target = target
        let prefix = prefix.isEmpty ? "" : "\(prefix): "
        
        return self.breakpoint(nil, { failure in
            target.write("\(prefix)break failure: (\(failure))")
            return true
        })
    }
    
}
#endif

#if canImport(Foundation)
import Foundation

extension Promise {
    public func measureTimeInterval(_ prefix: String = "") -> Promise<Output, Failure> {
        var target = PrintTarget()
        return self.measureTimeInterval(prefix, to: &target)
    }
    
    public func measureTimeInterval<Target: TextOutputStream>(_ prefix: String = "", to target: inout Target) -> Promise<Output, Failure> {
        var target = target
        let prefix = prefix.isEmpty ? "" : "\(prefix): "
        let startDate = Date()
        
        self.subscribe({ output in
            let timeInterval = Date().timeIntervalSince(startDate)
            target.write("\(prefix)receive output: [\(timeInterval)s] (\(output))")
        }, { failure in
            let timeInterval = Date().timeIntervalSince(startDate)
            target.write("\(prefix)receive failure: [\(timeInterval)s] (\(failure))")
        })
        
        return self
    }
}
#endif
