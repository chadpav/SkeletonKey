//
//  NewUserStateProcessor.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/14/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation

class NewUserState: StateProcessor {
    var dataService: DataService
    let deviceKeyGen: KeyGenStrategy

    required init(_ configuration: Configuration, _ presenter: SigninPresenterProtocol) {
        dataService = configuration.dataService
        deviceKeyGen = configuration.deviceKeyGenerator
    }

    func process(manager: SessionManager) {
        assert(dataService.currentAppUserID == nil, "Current App User should be nil")
        assert(dataService.getAppUsers().isEmpty, "App Users should be empty")
        
        manager.createNewUser()
    }
}
