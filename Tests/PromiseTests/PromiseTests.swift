import XCTest
import Promise

struct PromiseTestError: Error {}

extension FixedWidthInteger {
    var bitPattern: String {
        String(self, radix: 2).padding(toLength: self.bitWidth, withPad: " ", startingAt: 0)
    }
}

infix operator ^^

func ^^ (lhs: Bool, rhs: Bool) -> Bool {
    return lhs != rhs
}

final class PromiseIterationTest: XCTestCase {
    func testPassPromiseToC() {
        let promises = (0..<10000).map{ _ in Promise<Int, Never>.resolve(1) }
        
        do {
            let start = Date()
            for _ in 0..<100 {
                Promise<Int, Never>.combineAll(promises).sink{_ in }
            }
            print("default", Date().timeIntervalSince(start))
        }
        
        do {
            let start = Date()
            for _ in 0..<100 {
                Promise<Int, Never>.combineAll_fast(promises).sink{_ in }
            }
            print("fast", Date().timeIntervalSince(start))
        }
    }
}

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
        
        Promise.resolve("Hello World")
            .map{ $0 + "!" }
            .sink{
                XCTAssertEqual($0, "Hello World!")
                exp.fulfill()
            }
        wait(for: [exp], timeout: 1)
    }
    
    func testPromise_FlatMap() throws {
        let exp = expectation(description: "Promise complete")
        
        Promise.resolve("Hello World")
            .flatMap{ .resolve($0 + "!!!") }
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
        
        Promise<Int, PromiseTestError>.resolve(1)
            .flatMap{ .resolve($0 + 1) }
            .peek{ XCTAssertEqual($0, 2) }
            .flatMap{_ in Promise<Int, PromiseTestError>.reject(PromiseTestError()) }
            .peek{_ in XCTFail() }
            .catch{_ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testCombineAll() throws {
        let exp = expectation(description: "Promise complete")
        
        let promises = [
            Promise<Int, Never>.resolve(1),
            Promise<Int, Never>.resolve(2)
        ]
        
        promises.combineAll()
            .sink{
                XCTAssertEqual($0, [1, 2])
                exp.fulfill()
            }
        
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
