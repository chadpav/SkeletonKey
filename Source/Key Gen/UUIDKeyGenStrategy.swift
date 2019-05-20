//
//  UUIDKeyGenStrategy.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/15/19.
//  Copyright © 2019 AP Studio, LLC. All rights reserved.
//

import Foundation

public class UUIDKeyGenStrategy : KeyGenStrategy {
    public init() { }
    
    public func generate() -> String {
        return UUID().uuidString
    }
}
