//
//  UserDefaultsService.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/13/19.
//  Copyright © 2019 AP Studio, LLC. All rights reserved.
//

import Foundation

public protocol DataService {
    var appDeviceID: String? { get }
    var currentAppUserID: String? { get set }
    var isUserSet: Bool { get set }
    func save(appDeviceID: String)
    func save(currentAppUser: AppUser)
    func removeAppUser(with uid: String)
    func getAppUser(by uid: String) -> AppUser?
    func getAppUsers() -> [AppUser]
    func reset()
}

internal class DataStoreService : DataService {
    let defaults: UserDefaults
    let keychain: Keychain

    private enum KEYS: String {
        case appDeviceIDKey, currentAppUserIDKey, isUserSetKey, appUsersKey
    }

    internal var appDeviceID: String? {
        return try? keychain.getString(KEYS.appDeviceIDKey.rawValue)
    }

    internal var currentAppUserID: String? {
        get {
            return try? keychain.getString(KEYS.currentAppUserIDKey.rawValue)
        }
        set {
            if let uid = newValue {
                try? keychain.set(uid, key: KEYS.currentAppUserIDKey.rawValue)
            } else {
                try? keychain.remove(KEYS.currentAppUserIDKey.rawValue)
            }
        }
    }

    internal var isUserSet: Bool {
        get {
            return defaults.bool(forKey: KEYS.isUserSetKey.rawValue)
        }
        set {
            defaults.set(newValue, forKey: KEYS.isUserSetKey.rawValue)
        }
    }
    
    internal init(userDefaults ud: UserDefaults, keychain k: Keychain) {
        defaults = ud
        keychain = k
    }
    
    internal func save(appDeviceID: String) {
        guard currentAppUserID == nil else { fatalError("Device ID already set.") }

        try? keychain.set(appDeviceID, key: KEYS.appDeviceIDKey.rawValue)
    }

    internal func save(currentAppUser: AppUser) {
        // remove old AppUser if it exists
        var appUsers = filterAppUser(by: currentAppUser.uid)

        // add new AppUser
        appUsers.append(currentAppUser)

        // and save
        save(appUsers: appUsers)
    }

    internal func getAppUsers() -> [AppUser] {
        guard let data = try? keychain.getData(KEYS.appUsersKey.rawValue) else { return [] }

        let appUsers = try? PropertyListDecoder().decode([AppUser].self, from: data)

        return appUsers ?? []
    }

    internal func getAppUser(by uid: String) -> AppUser? {
        let appUsers = getAppUsers()
        return appUsers.first { return $0.uid == uid }
    }

    internal func removeAppUser(with uid: String) {
        let filteredAppUsers = filterAppUser(by: uid)
        save(appUsers: filteredAppUsers)
    }

    /*
     Reset all data.
    **/
    internal func reset() {
        try? keychain.removeAll()
        defaults.removeObject(forKey: KEYS.isUserSetKey.rawValue)
    }

    // MARK: Helpers

    private func filterAppUser(by uid: String) -> [AppUser] {
        var appUsers = getAppUsers()
        appUsers.removeAll { $0.uid == uid }
        return appUsers
    }

    private func save(appUsers: [AppUser]) {
        // archive, store, and sync across iCloud keychain
        let data = try! PropertyListEncoder().encode(appUsers)
        try? keychain.synchronizable(true).set(data, key: KEYS.appUsersKey.rawValue)
    }
}
