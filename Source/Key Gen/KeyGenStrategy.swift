//
//  KeyGenStrategy.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/15/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation

public protocol KeyGenStrategy {
    func generate() -> String
}
