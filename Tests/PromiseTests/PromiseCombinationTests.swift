import XCTest
import Promise

final class PromiseCombinationTests: XCTestCase {
    func testCombine_resultToBeTuple() {
        Promise<(Int, Int), Never>.combine(
            Promise.resolve(1),
            Promise.resolve(2)
        )
        .peek{
            XCTAssertEqual($0.0, 1)
            XCTAssertEqual($0.1, 2)
        }
        .waitUntilExit(self)
    }
    
    func testCombine_FromMultithread() {
        let promiseA = Promise<Int, Never>()
        let promiseB = Promise<Int, Never>()
        let promiseC = Promise<Int, Never>()
        let promiseD = Promise<Int, Never>()
        
        DispatchQueue.global().async { promiseA.resolve(1) }
        DispatchQueue.global().async { promiseB.resolve(2) }
        DispatchQueue.global().async { promiseC.resolve(3) }
        DispatchQueue.global().async { promiseD.resolve(4) }
        
        Promise<(Int, Int), Never>
            .combine(promiseA, promiseB, promiseC, promiseD)
            .peek{
                XCTAssertEqual($0.0, 1)
                XCTAssertEqual($0.1, 2)
                XCTAssertEqual($0.2, 3)
                XCTAssertEqual($0.3, 4)
            }
            .waitUntilExit(self)
    }
}
