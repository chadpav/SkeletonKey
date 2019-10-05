//
//  NoPresentationSigninPresenter.swift
//  SkeletonKey-iOS
//
//  Created by Chad Pavliska on 10/5/19.
//  Copyright © 2019 SkeletonKey. All rights reserved.
//

import Foundation

class NoPresentationSigninPresenter: SigninPresenterProtocol {
    var delegate: SignInDelegate?

    func present(appUser: AppUser) {
        delegate?.userSelected(appUser: appUser)
    }
}
