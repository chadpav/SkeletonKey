//
//  AppState.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/13/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import Foundation

public enum SessionState {
    case newUser, newSession, newDevice, newAppInstance, deletedUser

    func stateProcessor(_ configuration: Configuration, _ presenter: SigninPresenterProtocol) -> StateProcessor {
        switch self {
        case .newUser: return NewUserState(configuration, presenter)
        case .newSession: return NewSessionState(configuration, presenter)
        case .newDevice: return NewDeviceState(configuration, presenter)
        case .newAppInstance: return NewAppInstanceState(configuration, presenter)
        case .deletedUser: return DeletedUserState(configuration, presenter)
        }
    }
}
