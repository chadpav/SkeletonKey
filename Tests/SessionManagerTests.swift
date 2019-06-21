//
//  SessionManagerTests.swift
//  SkeletonKeyTests
//
//  Created by Chad Pavliska on 5/14/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import XCTest
import SkeletonKey

class SessionManagerTests: XCTestCase {

    let testAppUser = AppUser(uid: "u1234", displayName: "@chadpav", userName: "chadpav", password: "mypass")

    func testNewUserSession() {
        let mock = MockDataService()
        mock.currentAppUserID = nil
        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)
        let manager = SessionManager(configuration: config)

        let state = manager.checkState()

        XCTAssertEqual(state, SessionState.newUser)
    }

    func testNewDeviceSession() {
        let mock = MockDataService()
        mock.appDeviceID = nil
        mock.save(currentAppUser: testAppUser)
        mock.currentAppUserID = nil
        mock.isUserSet = false
        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)
        let manager = SessionManager(configuration: config)

        let state = manager.checkState()

        XCTAssertEqual(state, SessionState.newDevice)
    }

    func testNewSessionSession() {
        let mock = MockDataService()
        mock.appDeviceID = "someDeviceID"
        mock.save(currentAppUser: testAppUser)
        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)
        let manager = SessionManager(configuration: config)

        let state = manager.checkState()

        XCTAssertEqual(state, SessionState.newSession)
    }

    func testNewAppInstanceSession() {
        let mock = MockDataService()
        mock.appDeviceID = "someDeviceID"
        mock.save(currentAppUser: testAppUser)
        mock.isUserSet = false
        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)
        let manager = SessionManager(configuration: config)

        let state = manager.checkState()

        XCTAssertEqual(state, SessionState.newAppInstance)
    }

    func testDeletedUserSession() {
        let mock = MockDataService()
        mock.appDeviceID = "someDeviceID"
        mock.currentAppUserID = "someUserID"
        mock.isUserSet = true
        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)
        let manager = SessionManager(configuration: config)

        let state = manager.checkState()

        XCTAssertEqual(state, SessionState.deletedUser)
    }

    func testReturnNilUserIfUserIsNotSet() {
        let mock = MockDataService()
        mock.currentAppUserID = "someUserID"
        mock.isUserSet = false
        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)

        let manager = SessionManager(configuration: config)
        let currentUserID = manager.currentAppUserID

        XCTAssertNil(currentUserID)
    }

    func testReturnUserIfUserIsSet() {
        let mock = MockDataService()
        let someUserID = "someUserID"
        mock.currentAppUserID = someUserID
        mock.isUserSet = true
        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)

        let manager = SessionManager(configuration: config)
        let currentUserID = manager.currentAppUserID

        XCTAssertEqual(currentUserID, someUserID)
    }

    func testRemoveCurrentUser() {
        let mock = MockDataService()
        mock.save(currentAppUser: testAppUser)
        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)
        let manager = SessionManager(configuration: config)

        // Assert preconditions
        XCTAssertNotNil(manager.currentAppUserID)
        XCTAssertEqual(manager.appUsers.count, 1)

        // Test
        if let uid = manager.currentAppUserID {
            manager.removeAppUser(uid: uid)
        }

        XCTAssertNil(manager.currentAppUserID)
        XCTAssertFalse(manager.isUserSet)
        XCTAssertEqual(manager.appUsers.count, 0)
    }

    func testRemoveNotCurrentUser() {
        let mock = MockDataService()
        // add a different user
        let otherAppUser = AppUser(uid: "otherUser", displayName: nil, userName: nil, password: nil)
        mock.save(currentAppUser: otherAppUser)
        mock.save(currentAppUser: testAppUser)
        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)
        let manager = SessionManager(configuration: config)

        // Assert preconditions
        XCTAssertEqual(manager.currentAppUserID, testAppUser.uid)
        XCTAssertEqual(manager.appUsers.count, 2)

        // Test
        manager.removeAppUser(uid: otherAppUser.uid)

        XCTAssertEqual(manager.currentAppUserID, testAppUser.uid)
        XCTAssertTrue(manager.isUserSet)
        XCTAssertEqual(manager.appUsers.count, 1)
    }

    func testUpdateExistingAppUser() {
        let mock = MockDataService()

        // persist user without a password first
        let appUser = AppUser(uid: "aUser", displayName: "", userName: nil, password: nil)
        mock.save(currentAppUser: appUser)

        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)
        let manager = SessionManager(configuration: config)

        // Assert preconditions
        XCTAssertEqual(manager.currentAppUserID, appUser.uid)

        let updatedAppUser = AppUser(uid: "aUser", displayName: "Johnny Appleseed", userName: "japple@icloud.com", password: "pass1234")
        manager.updateAppUser(updatedAppUser)

        XCTAssertEqual(manager.currentAppUserID, appUser.uid)
        XCTAssertEqual(manager.appUsers.first?.password, "pass1234")
    }

    func testUpdateFailsWhenUserNotFound() {
        let mock = MockDataService()

        let config = Configuration(userProvider: MockUserProvider(), dataService: mock)
        let manager = SessionManager(configuration: config)

        XCTAssertEqual(manager.appUsers.count, 0)
        XCTAssertFalse(manager.isUserSet)

        let updatedAppUser = AppUser(uid: "aUser", displayName: "Johnny Appleseed", userName: "japple@icloud.com", password: "pass1234")
        manager.updateAppUser(updatedAppUser)

        XCTAssertEqual(manager.appUsers.count, 0)
        XCTAssertFalse(manager.isUserSet)
    }
}
