//
//  AppUser.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/13/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation

public struct AppUser: Codable {
    public let uid: String
    public let displayName: String?
    public let userName: String?
    public let password: String?

    public init(uid: String, displayName: String?, userName: String?, password: String?) {
        self.uid = uid
        self.displayName = displayName
        self.userName = userName
        self.password = password
    }
}
