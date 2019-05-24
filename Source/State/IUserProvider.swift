//
//  UserProviderProtocol.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/16/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation

public protocol IUserProvider {
    func provideUser(completion: @escaping (AppUser?, Error?) -> Void)
}
