//
//  UserProvider.swift
//  iOS Example
//
//  Created by Chad Pavliska on 5/16/19.
//  Copyright © 2019 AP Studio, LLC. All rights reserved.
//

import Foundation
import SkeletonKey

class UserProvider: IUserProvider {

    func provideUser() -> AppUser {

        // IMPLEMENTATION: Create a real user account for your app and provide the required parameters to AppUser below

        return AppUser(uid: UUID().uuidString, displayName: "chadpav@gmail.com", userName: nil, password: nil)
    }

}
