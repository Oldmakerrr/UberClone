//
//  LocationInputView.swift
//  Uber
//
//  Created by Apple on 12.06.2022.
//

import UIKit

protocol LocationInputViewDelegate: AnyObject {
    func didComplete(_ locationInputView: LocationInputView)
}

class LocationInputView: UIView {

    //MARK: - Properties
    
    weak var delegate: LocationInputViewDelegate?
    
    var user: User? {
        didSet {
            titleLabel.text = user?.fullname
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var startingLocationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Current location"
        textField.backgroundColor = .systemGray5
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.isEnabled = false
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var destinationLocationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter a destination.."
        textField.backgroundColor = .lightGray
        textField.returnKeyType = .search
        textField.font = UIFont.systemFont(ofSize: 14)
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "arrow.backward"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper function
    
    func configure() {
        backgroundColor = .white
        layer.applyShadow()
    }
    
    func setupViews() {
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor,
                          paddingTop: 44, paddingLeft: 12, width: 24, height: 25)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
        
        addSubview(startingLocationTextField)
        startingLocationTextField.anchor(top: backButton.bottomAnchor, left: leftAnchor, right: rightAnchor,
                                         paddingTop: 4, paddingLeft: 40, paddinRight: 40, height: 30)
        
        addSubview(destinationLocationTextField)
        destinationLocationTextField.anchor(top: startingLocationTextField.bottomAnchor, left: leftAnchor, right: rightAnchor,
                                         paddingTop: 12, paddingLeft: 40, paddinRight: 40, height: 30)
        
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.centerY(inView: startingLocationTextField, leftAnchor: leftAnchor, paddingLeft: 20)
        startLocationIndicatorView.setDimensions(height: 6)
        startLocationIndicatorView.layer.cornerRadius = 6 / 2
        
        addSubview(destinationIndicatorView)
        destinationIndicatorView.centerY(inView: destinationLocationTextField, leftAnchor: leftAnchor, paddingLeft: 20)
        destinationIndicatorView.setDimensions(height: 6)
        
        addSubview(linkingView)
        linkingView.centerX(inView: startLocationIndicatorView)
        linkingView.anchor(top: startLocationIndicatorView.bottomAnchor, bottom: destinationIndicatorView.topAnchor, paddingTop: 4, paddingBottom: 4, width: 0.5)
    }
    
    //MARK: - Selectors
    
    @objc private func handleBackTapped() {
        delegate?.didComplete(self)
    }

}
