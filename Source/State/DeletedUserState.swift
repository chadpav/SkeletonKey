//
//  DeletedUserState.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/19/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation

class DeletedUserState: StateProcessor {
    var dataService: DataService
    var presenter: SigninPresenterProtocol

    required init(_ configuration: Configuration, _ presenter: SigninPresenterProtocol) {
        dataService = configuration.dataService
        self.presenter = presenter
    }

    func process(manager: SessionManager) {
        let currentAppUserID = dataService.currentAppUserID
        assert(dataService.isUserSet == true, "User should be set")
        assert(dataService.currentAppUserID != nil, "Current App User should be nil")

        let appUsers = dataService.getAppUsers()
        let appUser = appUsers.first { $0.uid == currentAppUserID }
        assert(appUser == nil, "Should not have found an appUser")

        dataService.isUserSet = false
        dataService.currentAppUserID = nil
    }
}
