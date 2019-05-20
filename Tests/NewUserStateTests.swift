//
//  NewUserStateTests.swift
//  SkeletonKeyTests
//
//  Created by Chad Pavliska on 5/17/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import XCTest
import SkeletonKey

class NewUserStateTests: XCTestCase {
    var manager: SessionManager?

    override func setUp() {
        let mock = MockDataService()
        mock.appDeviceID = nil
        mock.isUserSet = false

        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)
        manager = SessionManager(configuration: config)
    }

    func testNewUserStateProcessing() {
        guard let manager = manager else {
            XCTAssertFalse(true)
            return
        }

        // validate pre-condition
        XCTAssertEqual(manager.checkState(), SessionState.newUser)

        let expectation = self.expectation(description: "Processing")

        manager.processState(completion: { (appUser) in
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(manager.checkState(), SessionState.newSession)
        XCTAssertNotNil(manager.appDeviceID)
        XCTAssertNotNil(manager.currentAppUserID)
        XCTAssertFalse(manager.appUsers.isEmpty)
        XCTAssertTrue(manager.isUserSet)
    }

}
