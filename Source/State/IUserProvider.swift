//
//  UserProviderProtocol.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/16/19.
//  Copyright © 2019 AP Studio, LLC. All rights reserved.
//

import Foundation

public protocol IUserProvider {
    func provideUser() -> AppUser
}
