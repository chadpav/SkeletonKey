//
//  SigninPresenter.swift
//  SkeletonKey
//
//  Created by Chad Pavliska on 5/19/19.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import UIKit

public protocol SigninPresenterProtocol {
    var delegate: SignInDelegate? { get set }
    func present(appUser: AppUser)
}

public protocol SignInDelegate: class {
    func userSelected(appUser: AppUser)
    func createNewUser()
}

class SigninPresenter: SigninPresenterProtocol {

    weak var delegate: SignInDelegate?

    private let dodgerBlue = UIColor(red: 0.01, green: 0.41, blue: 0.86, alpha: 1.0)
    private let panelHeight = CGFloat(220.0)
    private var selectedAppUser: AppUser?

    lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        return view
    }()

    lazy var panelView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    lazy var signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = dodgerBlue
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        button.addTarget(self, action: #selector(tappedSignIn), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()

    lazy var skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create new user", for: .normal)
        button.setTitleColor(dodgerBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        button.addTarget(self, action: #selector(tappedCreateNewUser), for: .touchUpInside)
        return button
    }()

    var constraint: NSLayoutConstraint?

    func present(appUser: AppUser) {
        guard let vc = UIApplication.shared.topMostViewController(),
            let view = vc.viewIfLoaded,
            let displayName = appUser.displayName else { return }

        selectedAppUser = appUser

        view.addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dimView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        // PANEL
        dimView.addSubview(panelView)
        panelView.translatesAutoresizingMaskIntoConstraints = false
        panelView.leadingAnchor.constraint(equalTo: dimView.leadingAnchor).isActive = true
        panelView.trailingAnchor.constraint(equalTo: dimView.trailingAnchor).isActive = true
        panelView.heightAnchor.constraint(equalToConstant: panelHeight).isActive = true
        constraint = NSLayoutConstraint(item: panelView, attribute: .bottom, relatedBy: .equal, toItem: dimView, attribute: .bottom, multiplier: 1, constant: panelHeight * 1)
        view.addConstraint(constraint!)


        // SIGN IN BUTTON
        signInButton.setTitle("\(displayName)", for: .normal)
        panelView.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        signInButton.widthAnchor.constraint(equalToConstant: 250.0).isActive = true
        signInButton.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 50.0).isActive = true
        signInButton.centerXAnchor.constraint(equalTo: panelView.centerXAnchor, constant: 0.0).isActive = true


        // SKIP BUTTON
        panelView.addSubview(skipButton)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 25.0).isActive = true
        skipButton.centerXAnchor.constraint(equalTo: panelView.centerXAnchor, constant: 0.0).isActive = true

        // ANIMATE IN
        view.layoutIfNeeded()
        constraint?.constant = 0.0
        UIView.animate(withDuration: 0.2) {
            self.dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            view.layoutIfNeeded()
        }

    }

    // MARK: - Button Actions

    @objc
    func tappedSignIn(sender: UIButton) {
        guard let selectedAppUser = selectedAppUser else { return }

        sender.isEnabled = false
        delegate?.userSelected(appUser: selectedAppUser)
        dimView.removeFromSuperview()
    }

    @objc
    func tappedCreateNewUser(sender: UIButton) {
        sender.isEnabled = false
        delegate?.createNewUser()
        dimView.removeFromSuperview()
    }

}
