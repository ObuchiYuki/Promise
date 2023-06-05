//
//  File.swift
//  
//
//  Created by yuki on 2023/06/04.
//


#if canImport(Foundation)
import Foundation

extension Promise {
    public func measureInterval(_ prefix: String = "") -> Promise<Output, Failure> {
        var target = PrintTarget()
        return self.measureInterval(prefix, to: &target)
    }
    
    public func measureInterval<Target: TextOutputStream>(_ prefix: String = "", to target: inout Target) -> Promise<Output, Failure> {
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

