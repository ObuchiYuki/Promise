import XCTest
import Promise

final class PromiseCombinationTest: XCTestCase {
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
    
    
    func testCombine_SpeedCheck_NormalCombineAll() {
        let promises = (0..<100_000).map{ _ in Promise<Int, Never>.resolve(1) }
        
        measure {
            Promise<Int, Never>.combineAll(promises).sink{_ in }
        }
    }
    
    func testCombine_SpeedCheck_FastCombineAll() {
        let promises = (0..<100_000).map{ _ in Promise<Int, Never>.resolve(1) }
        
        measure {
            Promise<Int, Never>.combineAll_fast(promises).sink{_ in }
        }
    }
}
