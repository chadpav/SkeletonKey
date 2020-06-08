//
//  NewDeviceStateTests.swift
//  SkeletonKeyTests
//
//  Created by Chad Pavliska on 5/17/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import XCTest
import SkeletonKey

class NewDeviceStateTests: XCTestCase {

    let testAppUser = AppUser(uid: "u1234", displayName: "@chadpav", userName: "chadpav", password: "mypass")
    var manager: SessionManager?

    override func setUp() {
        let mock = MockDataService()
        mock.appDeviceID = nil
        mock.save(currentAppUser: testAppUser)
        mock.currentAppUserID = nil
        mock.isUserSet = false
        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)
        manager = SessionManager(configuration: config, MockSignInPresenter())
    }

    func testNewDeviceStateProcessing() {
        // validate pre-condition
        XCTAssertEqual(manager?.checkState(), SessionState.newDevice)

        let expectation = self.expectation(description: "Processing")

        manager?.processState(completion: { (appUser, error) in
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertNotNil(manager?.appDeviceID)
    }

}
