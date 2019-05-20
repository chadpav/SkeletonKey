//
//  NewDeviceState.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/17/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation
import UIKit

class NewDeviceState: StateProcessor {
    var dataService: DataService
    let deviceKeyGen: KeyGenStrategy
    var presenter: SigninPresenterProtocol

    required init(_ configuration: Configuration, _ presenter: SigninPresenterProtocol) {
        dataService = configuration.dataService
        deviceKeyGen = configuration.deviceKeyGenerator
        self.presenter = presenter
    }

    func process(manager: SessionManager) {
        let appUsers = dataService.getAppUsers()

        // it doesn't really matter if device id is set or not. If we have AppUsrs
        // but a current app user isn't set then we need to initialize this as a new device

        assert(appUsers.count > 0, "Existing users are required.")
        assert(dataService.isUserSet == false, "User Set should not be true.")

        if dataService.appDeviceID == nil {
            dataService.save(appDeviceID: deviceKeyGen.generate())
        }

        if let firstUser = appUsers.first {
            presenter.delegate = manager
            presenter.present(appUser: firstUser)
        } else {
            manager.createNewUser()
        }
    }
}
