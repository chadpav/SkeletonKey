//
//  Manager.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/13/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation

public class SessionManager {
    private var dataStoreService: DataService
    private var presenter: SigninPresenterProtocol
    private let configuration: Configuration

    internal var state: SessionState?

    /**
     A unique ID for this device. Will persist on this device across app installs until a hard reset.
    */
    public var appDeviceID: String? {
        return dataStoreService.appDeviceID
    }

    /**
     The unique ID of the current app user
     */
    public var currentAppUserID: String? {
        guard isUserSet else { return nil }
        return dataStoreService.currentAppUserID
    }

    /**
     True if user has been set on this app instance of this device. Otherwise, indicates this is a new device
    */
    public var isUserSet: Bool {
        return dataStoreService.isUserSet
    }

    /**
     A list of AppUser's associated with the apple id currently authenticated on the device. AppUser's are
     synchronized using iCloud Keychain when it's enabled.
    */
    public var appUsers: [AppUser] {
        return dataStoreService.getAppUsers()
    }

    // MARK: Initializers

    public init(configuration: Configuration, _ presenter: SigninPresenterProtocol? = nil) {
        self.configuration = configuration
        self.dataStoreService = configuration.dataService
        self.presenter = presenter ?? SigninPresenter()
    }

    // MARK: Functions

    /**
     Return the current state of the session but will not alter the state.
    */
    public func checkState() -> SessionState {
        var state: SessionState?
        let appUsers = dataStoreService.getAppUsers()

        if let currentAppUserID = dataStoreService.currentAppUserID,
           dataStoreService.getAppUser(by: currentAppUserID) == nil {
            state = .deletedUser

        } else if dataStoreService.isUserSet {
            state = .newSession

        } else if dataStoreService.appDeviceID == nil  {
            if appUsers.isEmpty {
                state = .newUser
            } else {
                state = .newDevice
            }

        } else if dataStoreService.appDeviceID != nil &&
            dataStoreService.currentAppUserID != nil &&
            dataStoreService.isUserSet == false {
            state = .newAppInstance

        } else if dataStoreService.appDeviceID != nil &&
            dataStoreService.isUserSet == false &&
            appUsers.isEmpty == false {
            state = .newDevice

        } else {
            state = .newUser
        }

        // default to new user
        return state ?? .newUser
    }

    /**
     Will apply logic to handle the current session state. Call this method after handling current state so
     the framework performs magic.
    */
    var processor: StateProcessor?
    var onCompletion: ((AppUser) -> Void)?
    public func processState(completion: ((AppUser) -> Void)?) {
        onCompletion = completion
        let state = checkState()
        processor = state.stateProcessor(configuration, presenter)
        processor?.process(manager: self)
    }

    /**
     Remove the AppUser with matching id from the users Keychain. Changes will be synced across devices.
    */
    public func removeAppUser(uid: String) {
        if uid == dataStoreService.currentAppUserID {
            dataStoreService.currentAppUserID = nil
            dataStoreService.isUserSet = false
        }

        dataStoreService.removeAppUser(with: uid)
    }

    public func reset() {
        dataStoreService.reset()
    }

    internal func finish() {
        if let appUser = dataStoreService.getAppUser(by: dataStoreService.currentAppUserID ?? "") {
            onCompletion?(appUser)
        }
    }
}

extension SessionManager: SignInDelegate {

    public func userSelected(appUser: AppUser) {
        dataStoreService.currentAppUserID = appUser.uid
        dataStoreService.isUserSet = true
        onCompletion?(appUser)
    }

    public func createNewUser() {
        if dataStoreService.appDeviceID == nil {
            dataStoreService.save(appDeviceID: configuration.deviceKeyGenerator.generate())
        }

        let appUser = configuration.userProvider.provideUser()
        dataStoreService.save(currentAppUser: appUser)
        dataStoreService.currentAppUserID = appUser.uid
        dataStoreService.isUserSet = true
        onCompletion?(appUser)
    }

}