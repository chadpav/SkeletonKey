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

    lazy var signInLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .light)
        label.text = "Continue with existing user?"
        return label
    }()

    lazy var signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = dodgerBlue
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        button.addTarget(self, action: #selector(tappedSignIn), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()

    lazy var signInActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    lazy var skipActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.tintColor = dodgerBlue
        indicator.hidesWhenStopped = true
        return indicator
    }()

    lazy var skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create New User", for: .normal)
        button.setTitleColor(dodgerBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        button.addTarget(self, action: #selector(tappedCreateNewUser), for: .touchUpInside)
        return button
    }()

    var constraint: NSLayoutConstraint?

    func present(appUser: AppUser) {
        guard let vc = UIApplication.shared.topMostViewController(),
            let view = vc.viewIfLoaded
            else { return }

        selectedAppUser = appUser

        // PANEL
        view.addSubview(panelView)
        panelView.translatesAutoresizingMaskIntoConstraints = false
        panelView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        panelView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        panelView.heightAnchor.constraint(equalToConstant: panelHeight).isActive = true
        constraint = NSLayoutConstraint(item: panelView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: panelHeight * 1)
        view.addConstraint(constraint!)

        // DIM VIEW
        panelView.addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor).isActive = true
        dimView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dimView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: panelView.topAnchor).isActive = true

        // SIGN IN LABEL
        panelView.addSubview(signInLabel)
        signInLabel.translatesAutoresizingMaskIntoConstraints = false
        signInLabel.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 18.0).isActive = true
        signInLabel.centerXAnchor.constraint(equalTo: panelView.centerXAnchor).isActive = true

        // SIGN IN BUTTON
        if let displayName = appUser.displayName, !displayName.isEmpty {
            signInButton.setTitle("Use \"\(displayName)\"", for: .normal)
        } else if let userName = appUser.userName, !userName.isEmpty {
            signInButton.setTitle("Use \"\(userName)\"", for: .normal)
        } else {
            signInButton.setTitle("Use Existing User", for: .normal)
        }
        panelView.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        signInButton.widthAnchor.constraint(equalToConstant: 275.0).isActive = true
        signInButton.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 55.0).isActive = true
        signInButton.centerXAnchor.constraint(equalTo: panelView.centerXAnchor).isActive = true

        // SKIP BUTTON
        panelView.addSubview(skipButton)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 25.0).isActive = true
        skipButton.centerXAnchor.constraint(equalTo: panelView.centerXAnchor, constant: 0.0).isActive = true

        // ACTIVITY INDICATORS
        signInButton.addSubview(signInActivityIndicator)
        signInActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        signInActivityIndicator.centerYAnchor.constraint(equalTo: signInButton.centerYAnchor).isActive = true
        signInActivityIndicator.centerXAnchor.constraint(equalTo: signInButton.centerXAnchor).isActive = true
        skipButton.addSubview(skipActivityIndicator)
        skipActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        skipActivityIndicator.centerYAnchor.constraint(equalTo: skipButton.centerYAnchor).isActive = true
        skipActivityIndicator.centerXAnchor.constraint(equalTo: skipButton.centerXAnchor).isActive = true

        // ANIMATE IN
        animateIn(to: view)
    }

    // MARK: - Animations

    func animateIn(to view: UIView) {
        view.layoutIfNeeded()
        constraint?.constant = 0.0
        UIView.animate(withDuration: 0.2) {
            self.dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            view.layoutIfNeeded()
        }
    }

    func animateOut() {
        UIView.animate(withDuration: 0.2, animations: {
            self.panelView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        }) { finished in
            self.panelView.removeFromSuperview()
        }
    }

    // MARK: - Button Actions

    @objc
    func tappedSignIn(sender: UIButton) {
        guard let selectedAppUser = selectedAppUser else { return }

        sender.isEnabled = false
        sender.titleLabel?.text = ""
        signInActivityIndicator.startAnimating()

        delegate?.userSelected(appUser: selectedAppUser)
        animateOut()
    }

    @objc
    func tappedCreateNewUser(sender: UIButton) {
        sender.isEnabled = false

        skipButton.titleLabel?.text = ""
        skipActivityIndicator.startAnimating()

        delegate?.createNewUser()
        animateOut()
    }

}
