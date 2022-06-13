//
//  SignUpViewController.swift
//  Uber
//
//  Created by Apple on 10.06.2022.
//

import UIKit
import Firebase

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
        return UITextField().textField(withPlaceholder: "Fullname")
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
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
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
    
    @objc private func handleSignUp() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let fullName = fullNameTextField.text else { return }
        let accountTypeIndex = accountTypeSegmentedController.selectedSegmentIndex
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Failed to register user with error \(error.localizedDescription)")
                return
            }
            guard let uid = result?.user.uid else { return }
            print("DEBUG: User successfuly register, user id = \(uid)")
            let values = ["email": email,
                          "fullname": fullName,
                          "accountType": accountTypeIndex] as [String:Any]
            Database.database().reference().child("users").child(uid).updateChildValues(values) { error, ref in
                if let error = error {
                    print("DEBUG: Failed to save user data with error: \(error.localizedDescription)")
                }
                print("DEBUG: Successfuly save data..")
                DispatchQueue.main.async {
                    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                    if let homeController = keyWindow?.rootViewController as? HomeController {
                        homeController.configureUI()
                    }
                }
                self.dismiss(animated: true)
            }
        }
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

