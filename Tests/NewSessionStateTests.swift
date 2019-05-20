//
//  NewSessionStateTests.swift
//  SkeletonKeyTests
//
//  Created by Chad Pavliska on 5/17/19.
//  Copyright © 2019 AP Studio, LLC. All rights reserved.
//

import XCTest
import SkeletonKey

class NewSessionStateTests: XCTestCase {

    let testAppUser = AppUser(uid: "u1234", displayName: "@chadpav", userName: "chadpav", password: "mypass")
    var manager: SessionManager?

    override func setUp() {
        let mock = MockDataService()
        mock.appDeviceID = "someDeviceID"
        mock.save(currentAppUser: testAppUser)
        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)
        manager = SessionManager(configuration: config, MockSignInPresenter())
    }

    func testNewDeviceStateProcessing() {
        guard let manager = manager else {
            XCTAssertFalse(true)
            return
        }

        // validate pre-condition
        XCTAssertEqual(manager.checkState(), SessionState.newSession)

        let expectation = self.expectation(description: "Processing")

        manager.processState(completion: { (appUser) in
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(manager.checkState(), SessionState.newSession)
        XCTAssertNotNil(manager.appDeviceID)
        XCTAssertNotNil(manager.currentAppUserID)
        XCTAssertTrue(manager.isUserSet)
    }

}
