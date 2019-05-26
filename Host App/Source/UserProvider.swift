//
//  UserProvider.swift
//  iOS Example
//
//  Created by Chad Pavliska on 5/16/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation
import SkeletonKey

class UserProvider: IUserProvider {

    let appUser = AppUser(uid: UUID().uuidString, displayName: "my.email@gmail.com", userName: nil, password: nil)

    func provideUser(completion: @escaping (AppUser?, Error?) -> Void) {

        // IMPLEMENTATION: Create a real user account for your app and provide the required parameters to AppUser below

        completion(appUser, nil)
    }

}
