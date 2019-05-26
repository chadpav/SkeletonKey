//
//  MockUserProvider.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/16/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation
import SkeletonKey

class MockUserProvider: IUserProvider {
    let appUser = AppUser(uid: "1234", displayName: "Display Name", userName: "username", password: "pass1234")

    public init() { }

    func provideUser(completion: @escaping (AppUser?, Error?) -> Void) {
        completion(appUser, nil)
    }

}
