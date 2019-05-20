//
//  StateProcessor.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/14/19.
//  Copyright © 2019 AP Studio, LLC. All rights reserved.
//

import Foundation

protocol StateProcessor {
    init(_ configuration: Configuration, _ presenter: SigninPresenterProtocol)
    func process(manager: SessionManager)
}
