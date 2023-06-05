import XCTest
@testable import Promise

private let testBreakPoint = false

final class PromiseTestsBreakPoint: XCTestCase {
    func testPromise_BreakPoint() {
        Promise.resolve(10)
            .breakpoint({ _ in return testBreakPoint })
            .sink{ print($0) }
    }
}
