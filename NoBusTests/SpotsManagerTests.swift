//
//  SpotsManagerTests.swift
//  NoBusTests
//
//  Created by Gao on 2018/10/25.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import XCTest
@testable import NoBus

func itWait(description: String = "",
            timeout:TimeInterval = 10,
            action:( _ done:@escaping ()->Void ) -> Void) {
    let expection = XCTestExpectation(description: description)
    let done = {
        expection.fulfill()
    }
    action(done)
    let result = XCTWaiter().wait(for: [expection], timeout: timeout)
    XCTAssert(result == .completed)
}

class SpotsManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_getSpots() {
        itWait { (done) in
            SpotsManager.shared.getAllSpot { (spots) in
                XCTAssert(spots.count > 0)
                let spot = spots[0]
                XCTAssert(spot.stations.count > 0)
                let generalStation = spot.stations[0]
                print(generalStation.stationsInLines)
                XCTAssert(generalStation.stationsInLines.count > 0)
                done()
            }
        }
    }


}
