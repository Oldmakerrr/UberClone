//
//  SignUpViewController.swift
//  Uber
//
//  Created by Apple on 10.06.2022.
//

import UIKit

class SignUpViewController: UIViewController {
    
    //MARK: Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor.init(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(named: "icon-mail")?.withRenderingMode(.alwaysTemplate), textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "lock"), textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var fullNameContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "person.circle"), textField: fullNameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var accountTypeContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "person.circle.fill"), segmentedController: accountTypeSegmentedController)
        view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return view
    }()
    
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email")
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password",
                                       isSecureTextEntry: true)
    }()
    
    private let fullNameTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Fullname",
                                       isSecureTextEntry: true)
    }()
    
    private let accountTypeSegmentedController: UISegmentedControl = {
        let segmetedController = UISegmentedControl(items: ["Rider", "Driver"])
        segmetedController.backgroundColor = .backGroundColor
        segmetedController.tintColor = UIColor(white: 1, alpha: 0.87)
        segmetedController.selectedSegmentIndex = 0
        return segmetedController
    }()
    
    private let signUpButton: AuthButton = {
        let button = AuthButton()
        button.setTitle("Sign Up", for: .normal)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributeTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributeTitle.append(NSAttributedString(string: "Sign Up", attributes: [
            NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        
        button.addTarget(self, action: #selector(handleSnowLoggin), for: .touchUpInside)
        
        button.setAttributedTitle(attributeTitle, for: .normal)
        return button
    }()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super .viewDidLoad()
        configureUI()
        
    }
    
    //MARK: Selectors
    
    @objc private func handleSnowLoggin() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Helper Methods
    
    func configureUI() {
        view.backgroundColor = .backGroundColor
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        let stackView = UIStackView(arrangedSubviews: [emailContainerView,
                                                       fullNameContainerView,
                                                       passwordContainerView,
                                                       accountTypeContainerView,
                                                       signUpButton])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 24
        view.addSubview(stackView)
        stackView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
                         right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddinRight: 16)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
       
    }
}

