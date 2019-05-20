//
//  NewAppInstanceState.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/17/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation

class NewAppInstanceState: StateProcessor {
    var dataService: DataService
    let deviceKeyGen: KeyGenStrategy
    var presenter: SigninPresenterProtocol
    
    required init(_ configuration: Configuration, _ presenter: SigninPresenterProtocol) {
        dataService = configuration.dataService
        deviceKeyGen = configuration.deviceKeyGenerator
        self.presenter = presenter
    }

    func process(manager: SessionManager) {
        assert(dataService.appDeviceID != nil, "Device State should not be nil.")
        assert(dataService.currentAppUserID != nil, "Current App User ID should not be nil.")
        assert(dataService.isUserSet == false, "User should not be set.")

        let appUsers = dataService.getAppUsers()
        if let firstUser = appUsers.first {
            presenter.delegate = manager
            presenter.present(appUser: firstUser)
        } else {
            manager.createNewUser()
        }
    }
}
