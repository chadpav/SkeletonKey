//
//  NewAppInstanceStateTests.swift
//  SkeletonKeyTests
//
//  Created by Chad Pavliska on 5/17/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import XCTest
import SkeletonKey

class NewAppInstanceStateTests: XCTestCase {

    let testAppUser = AppUser(uid: "u1234", displayName: "@chadpav", userName: "chadpav", password: "mypass")
    let deviceID = "someDeviceID"
    var manager: SessionManager?

    override func setUp() {
        let mock = MockDataService()
        mock.appDeviceID = deviceID
        mock.save(currentAppUser: testAppUser)
        mock.isUserSet = false
        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)
        manager = SessionManager(configuration: config, MockSignInPresenter())
    }

    func testNewDeviceStateProcessing() {
        // validate pre-condition
        XCTAssertEqual(manager?.checkState(), SessionState.newAppInstance)
        let expectation = self.expectation(description: "Processing")

        manager?.processState(completion: { (appUser) in
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(manager?.isUserSet ?? false)
        XCTAssertEqual(manager?.appDeviceID, deviceID)
    }

}
