//
//  MockSignInPresenter.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/19/19.
//  Copyright © 2019 AP Studio, LLC. All rights reserved.
//

import Foundation
import SkeletonKey

class MockSignInPresenter : SigninPresenterProtocol {
    weak var delegate: SignInDelegate?

    func present(appUser: AppUser) {
        delegate?.userSelected(appUser: appUser)
    }
}
