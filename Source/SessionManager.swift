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
     The current AppUser
     */
    public var currentAppUser: AppUser? {
        guard let uid = dataStoreService.currentAppUserID else { return nil }
        return appUsers.first(where: { $0.uid == uid })
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
        if let presenter = presenter {
            self.presenter = presenter
        } else {
            self.presenter = configuration.promptReturningUsers
                ? SigninPresenter()
                : NoPresentationSigninPresenter()
        }
    }

    // MARK: Functions

    /**
    Adds an AppUser in the Keychain. Will throw a ValidateError if an existing AppUser with the same 'uid' is found.
     */
    public func addAppUser(_ appUser: AppUser) throws {
        // check for duplicates, user should use update for existing users to avoid implicit behavior
        guard appUsers.filter({ return $0.uid == appUser.uid }).count == 0 else {
            throw ValidationError.duplicateFound
        }

        dataStoreService.save(currentAppUser: appUser)

        if currentAppUser == nil {
            dataStoreService.isUserSet = true
            dataStoreService.currentAppUserID = appUser.uid
        }
    }

    /**
     Updates AppUser in Keychain. Will not save an appUser unless they already exist. Will overwrite all
     properties, you should request current appUser and update only properties you want to change.
    */
    public func updateAppUser(_ appUser: AppUser) {
        if appUsers.filter({ return $0.uid == appUser.uid }).count > 0 {
            dataStoreService.save(currentAppUser: appUser)
        }
    }

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
    var onCompletion: ((AppUser?, Error?) -> Void)?
    public func processState(completion: ((AppUser?, Error?) -> Void)?) {
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
        let appUser = dataStoreService.getAppUser(by: dataStoreService.currentAppUserID ?? "")
        onCompletion?(appUser, nil)
    }
}

extension SessionManager: SignInDelegate {

    public func userSelected(appUser: AppUser) {
        dataStoreService.currentAppUserID = appUser.uid
        dataStoreService.isUserSet = true
        onCompletion?(appUser, nil)
    }

    public func createNewUser() {
        if dataStoreService.appDeviceID == nil {
            dataStoreService.save(appDeviceID: configuration.deviceKeyGenerator.generate())
        }

        configuration.userProvider.provideUser { appUser, error in
            if let error = error {
                self.onCompletion?(nil, error)
            } else {
                if let appUser = appUser {
                    self.dataStoreService.save(currentAppUser: appUser)
                    self.dataStoreService.currentAppUserID = appUser.uid
                    self.dataStoreService.isUserSet = true
                }
                self.onCompletion?(appUser, nil)
            }

        }
    }

}
