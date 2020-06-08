//
//  ValidationError.swift
//  SkeletonKey-iOS
//
//  Created by Chad Pavliska on 6/8/20.
//  Copyright © 2020 SkeletonKey. All rights reserved.
//

import Foundation

enum ValidationError: Error {
    case duplicateFound
}

extension ValidationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .duplicateFound:
            return NSLocalizedString("Duplicate App User found. Try update App User instead.", comment: "Duplicate Found validation error description")
        }
    }
}
