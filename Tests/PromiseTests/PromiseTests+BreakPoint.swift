import XCTest
@testable import Promise

private let testBreakPoint = false

final class PromiseTestsBreakPoint: XCTestCase {
    func testPromise_BreakPoint() {
  
    }
}

final class PromiseTestsCancel: XCTestCase {
    func testPromise_Cancel() {
        let promise = Promise<Int, Error>.cancelable{ resolve, reject, onCancel in
            onCancel{
                print("Cancel")
            }
        }
        
        promise.cancel()
    }
}

/*
 let (promise, cancel) = Promise<Int, Error>.cancelable{ resolve, reject, onCancel in
    let task = Task()
 
    task.receive{
        ...
    }
 
    onCancel{
        task.cancel()
    }
 }
 
 promise.map{ ... }
 
 cancel.cancel()
 
 
 */
