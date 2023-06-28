import XCTest
@testable import Promise

protocol PromiseIterator<Element> {
    associatedtype Element
    
    func next() -> Promise<Element?, Never>
}

func for_promise<Iterator: PromiseIterator>(_ iterator: Iterator, _ block: @escaping (Iterator.Element, inout Bool) -> ()) {
    var promise = iterator.next()
    
        
}


final class PromiseTestsLoop: XCTestCase {
    func testPromise_loop() {
        class IntIterator: PromiseIterator {
            func next() -> Promise<Int?, Never> { .resolve(1) }
        }
        
        let iterator = IntIterator()
        var count = 0
        for_promise(iterator) { value, stop in
            print(count)
            count += 1
            if count > 10000 {
                stop = true
            }
        }
    }
}

final class PromiseTestsMultithread: XCTestCase {
    func testMultithreadCombine() {
        let end = expectation(description: "")
        
        let promises = (0..<100).map{_ in Promise<Int, Never>() }
        
        for i in 0..<100 {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
                promises[i].fulfill(i)
            }
        }
        
        promises.combineAll()
            .sink{
                XCTAssertEqual($0, (0..<100).map{ $0 })
                end.fulfill()
            }
        
        wait(for: [end], timeout: 0.1)
    }
    
    func testMultithreadCombine_2() {
        let end = expectation(description: "")
        
        let promises = (0..<4).map{_ in Promise<Int, Never>() }
        
        for i in 0..<4 {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
                promises[i].fulfill(i)
            }
        }
        
        let res = Promise<Int, Never>.combine(promises[0], promises[1], promises[2], promises[3])
        
        res.sink{
            XCTAssert($0 == (0, 1, 2, 3))
            end.fulfill()
        }
        
        
        wait(for: [end], timeout: 0.1)
    }
    
    
    func testMultithreadMerge() {
        let end = expectation(description: "")
        
        let promises = (0..<100).map{_ in Promise<Int, Never>() }
        
        for i in 0..<100 {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
                promises[i].fulfill(i)
            }
        }
        
        var caller = 0
        promises.mergeAll()
            .sink{_ in caller += 1 }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            XCTAssertEqual(caller, 1)
            end.fulfill()
        }
        
        wait(for: [end])
    }
    
    func testMayDeadLock() {
        let end = expectation(description: "")
        let promise = Promise<Int, Never>()
        
        promise
            .sink{ promise.fulfill($0); end.fulfill() }
        
        promise.fulfill(1)
        
        wait(for: [end])
    }
    
    func testDispatchWorks() {
        let end = expectation(description: "")
        let promise = Promise<Int, Never>()
        
        var caller = 0
        promise.sink{_ in caller += 1 }
        
        for i in 0..<100 {
            DispatchQueue.global().asyncAfter(deadline: .now()+0.01) {
                promise.fulfill(i)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            XCTAssertEqual(caller, 1)
            end.fulfill()
        }
        
        wait(for: [end])
    }
}
