//
//  Configuration.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/15/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation

public struct Configuration {
    public let deviceKeyGenerator: KeyGenStrategy
    public let userProvider: IUserProvider
    let keychain: Keychain
    let defaults: UserDefaults
    let dataService: DataService
    let promptReturningUsers: Bool

    public init(userProvider: IUserProvider,
                service: String? = nil,
                deviceKeyGenerator: KeyGenStrategy? = nil,
                dataService: DataService? = nil,
                promptReturningUsers: Bool = true) {

        let keychainService = service ?? Bundle.main.bundleIdentifier ?? ""
        keychain = Keychain(service: keychainService)
        defaults = UserDefaults.standard
        self.userProvider = userProvider
        self.deviceKeyGenerator = deviceKeyGenerator ?? UUIDKeyGenStrategy()
        self.promptReturningUsers = promptReturningUsers

        if let dataService = dataService {
            self.dataService = dataService
        } else {
            self.dataService = DataStoreService(userDefaults: defaults, keychain: keychain)
        }
    }

}
