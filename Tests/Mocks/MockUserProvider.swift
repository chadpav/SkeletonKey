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

    public init() { }
    
    func provideUser() -> AppUser {
        return AppUser(uid: "1234", displayName: "Display Name", userName: "username", password: "pass1234")
    }
}
