//
//  DeletedUserStateTests.swift
//  SkeletonKeyTests
//
//  Created by Chad Pavliska on 5/19/19.
//  Copyright © 2019 AP Studio, LLC. All rights reserved.
//

import XCTest
import SkeletonKey

class DeletedUserStateTests: XCTestCase {

    let testAppUser = AppUser(uid: "u1234", displayName: "@chadpav", userName: "chadpav", password: "mypass")
    let deviceID = "someDeviceID"
    let userID = "someUserID"
    var manager: SessionManager?
    var mockDataService: MockDataService?
    
    override func setUp() {
        mockDataService = MockDataService()
        mockDataService?.appDeviceID = deviceID
        mockDataService?.currentAppUserID = userID
        mockDataService?.isUserSet = true
        let config = Configuration(userProvider: MockUserProvider(), dataService: mockDataService)
        manager = SessionManager(configuration: config, MockSignInPresenter())
    }

    func testDeletedOnlyUserClearsCurrentUser() {
        // validate pre-condition
        XCTAssertEqual(manager?.checkState(), SessionState.deletedUser)

        let expectation = self.expectation(description: "Processing")

        manager?.processState(completion: { (appUser) in
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(manager?.isUserSet ?? false)
        XCTAssertEqual(manager?.appDeviceID, deviceID)
        XCTAssertNotEqual(manager?.currentAppUserID, userID)
    }

    func testDeletedOneOfMultipleUsersClearsCurrentUser() {
        let anotherAppUser = AppUser(uid: "anotherUser", displayName: "Another", userName: nil, password: nil)
        mockDataService?.save(currentAppUser: anotherAppUser)
        mockDataService?.save(currentAppUser: testAppUser)
        mockDataService?.currentAppUserID = userID
        mockDataService?.isUserSet = true
        let config = Configuration(userProvider: MockUserProvider(), dataService: mockDataService)
        let manager = SessionManager(configuration: config, MockSignInPresenter())

        // validate pre-condition
        XCTAssertEqual(manager.checkState(), SessionState.deletedUser)

        let expectation = self.expectation(description: "Processing")

        manager.processState(completion: { (appUser) in
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(manager.isUserSet)
        XCTAssertEqual(manager.appDeviceID, deviceID)
        XCTAssertNotEqual(manager.currentAppUserID, userID)
    }

}
