//
//  Promise+Debug.swift
//
//
//  Created by yuki on 2021/08/23.
//


@usableFromInline struct PrintTarget: TextOutputStream {
    @usableFromInline func write(_ string: String) { Swift.print(string) }
    
    @inlinable init() {}
}

extension Promise {
    @inlinable
    public func assertNoFailure(_ prefix: String = "", file: StaticString = #file, line: UInt = #line) -> Promise<Output, Never> {
        let promise = Promise<Output, Never>()
        self.subscribe(promise.resolve, { error in
           let prefix = prefix.isEmpty ? "" : prefix + ": "
           fatalError("\(prefix)\(error)", file: file, line: line)
        })
        return promise
    }
    
    @inlinable
    public func print(_ prefix: String = "") -> Promise<Output, Failure> {
        var target = PrintTarget()
        return self.print(prefix, to: &target)
    }
    
    @inlinable
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

#if canImport(Darwin)
import Darwin

extension Promise {
    @inlinable
    public func breakpoint(@_implicitSelfCapture _ receiveOutput: ((Output) -> Bool)? = nil, @_implicitSelfCapture _ receiveFailure: ((Failure) -> Bool)? = nil) -> Promise<Output, Failure> {
        self.subscribe({ output in
            if receiveOutput?(output) == true { raise(SIGTRAP) }
        }, { failure in
            if receiveFailure?(failure) == true { raise(SIGTRAP) }
        })
        return self
    }

    @inlinable
    public func breakpointOnError(_ prefix: String = "") -> Promise<Output, Failure> {
        var target = PrintTarget()
        return self.breakpointOnError(prefix, to: &target)
    }
    
    @inlinable
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
