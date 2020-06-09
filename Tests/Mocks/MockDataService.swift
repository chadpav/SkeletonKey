//
//  MockDataService.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/14/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation
import SkeletonKey

class MockDataService: DataService {
    private var appUsers = [AppUser]()

    public var appDeviceID: String?
    public var currentAppUserID: String?
    public var isUserSet = false

    public init() { }
    
    public func save(appDeviceID: String) {
        self.appDeviceID = appDeviceID
    }

    public func save(currentAppUser: AppUser) {
        appUsers.removeAll { $0.uid == currentAppUser.uid }
        if appUsers.isEmpty {
            appUsers.append(currentAppUser)
            currentAppUserID = currentAppUser.uid
            isUserSet = true
        } else {
            appUsers.append(currentAppUser)
        }
    }

    public func getAppUser(by uid: String) -> AppUser? {
        return appUsers.first { $0.uid == uid }
    }

    public func getAppUsers() -> [AppUser] {
        return appUsers
    }

    func removeAppUser(with uid: String) {
        appUsers.removeAll { $0.uid == uid }
        if appUsers.isEmpty {
            currentAppUserID = nil
            isUserSet = false
        } else {
            currentAppUserID = appUsers.first?.uid
            isUserSet = true
        }
    }

    func reset() {
        appUsers.removeAll()
        appDeviceID = nil
        currentAppUserID = nil
        isUserSet = false
    }

    func debugPrint() {

    }
}
