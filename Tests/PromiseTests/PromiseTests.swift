import XCTest
import DequeModule
@testable import Promise

struct PromiseTestError: Error {}

final class PromiseTests: XCTestCase {
    func testPromise_Callback2Promise() throws {
        let exp = expectation(description: "Promise complete")
        Promise{ resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                resolve("Hello World")
            }
        }
        .sink{
            XCTAssertEqual($0, "Hello World")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func testPromise_Map() throws {
        let exp = expectation(description: "Promise complete")
        Promise(output: "Hello World")
            .map{ $0 + "!" }
            .sink{
                XCTAssertEqual($0, "Hello World!")
                exp.fulfill()
            }
        wait(for: [exp], timeout: 1)
    }
    
    func testPromise_FlatMap() throws {
        let exp = expectation(description: "Promise complete")
        
        Promise(output: "Hello World")
            .flatMap{ Promise(output: $0 + "!!!") }
            .sink{
                XCTAssertEqual($0, "Hello World!!!")
                exp.fulfill()
            }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testPromise_Reject() throws {
        let exp = expectation(description: "Promise complete")
        
        Promise<Void, PromiseTestError>{ _, reject in
            reject(PromiseTestError())
        }
        .sink({ XCTFail(); exp.fulfill() }, {_ in exp.fulfill() })
        
        wait(for: [exp], timeout: 1)
    }
    
    func testPromise_Chain() throws {
        let exp = expectation(description: "Promise complete")
        
        Promise<Int, PromiseTestError>(output: 1)
            .flatMap{ Promise(output: $0 + 1) }
            .peek{ XCTAssertEqual($0, 2) }
            .flatMap{_ in Promise<Int, PromiseTestError>(failure: PromiseTestError()) }
            .peek{_ in XCTFail() }
            .catch{_ in exp.fulfill() }
        
        
        
        wait(for: [exp], timeout: 1)
    }
    
    static var allTests = [
        ("testPromise_Chain", testPromise_Chain),
        ("testPromise_Reject", testPromise_Reject),
        ("testPromise_FlatMap", testPromise_FlatMap),
        ("testPromise_Map", testPromise_Map),
        ("testPromise_Callback2Promise", testPromise_Callback2Promise),
    ]
}
