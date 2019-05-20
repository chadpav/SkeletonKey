//
//  NewSessionStateProcessor.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/14/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation

class NewSessionState: StateProcessor {
    let dataService: DataService
    
    required init(_ configuration: Configuration, _ presenter: SigninPresenterProtocol) {
        dataService = configuration.dataService
    }

    func process(manager: SessionManager) {
        assert(dataService.appDeviceID != nil, "Device ID should be set")
        assert(dataService.getAppUsers().count > 0, "App Users should not be empty")
        assert(dataService.currentAppUserID != nil, "Current App User ID should be set")
        assert(dataService.isUserSet, "User should be set")

        // no-op

        // TODO: handle scenario where AppUser is removed from a second device
        // if currentUserID was removed then need to clear from keychain and session
        manager.finish()
    }

}
