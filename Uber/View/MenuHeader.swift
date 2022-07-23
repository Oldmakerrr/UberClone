//
//  MenuHeader.swift
//  Uber
//
//  Created by Apple on 29.06.2022.
//

import UIKit

enum MenuHeaderStyle {
    case white
    case black
}

class MenuHeader: UIView {
    
    //MARK: - Properties
    
   private let user: User
    
    private lazy var profileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.addSubview(initialLabel)
        initialLabel.centerX(inView: view)
        initialLabel.centerY(inView: view)
        return view
    }()
    
    private let initialLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 42)
        return label
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    //MARK: - Lifecycle
    
    init(frame: CGRect = .zero, user: User, style: MenuHeaderStyle) {
        self.user = user
        super.init(frame: frame)
        fullNameLabel.text = user.fullname
        emailLabel.text = user.email
        initialLabel.text = user.firstInitial
        setupView()
        switch style {
        case .white:
            backgroundColor = .white
            fullNameLabel.textColor = .black
            initialLabel.textColor = .white
        case .black:
            backgroundColor = .backGroundColor
            fullNameLabel.textColor = .white
            initialLabel.textColor = .white
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper Functions
    
    private func setupView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor,
                                paddingTop: 12, paddingLeft: 12  ,
                                width: 64, height: 64)
        profileImageView.layer.cornerRadius = 64 / 2
        
        let stack = UIStackView(arrangedSubviews: [fullNameLabel, emailLabel])
        addSubview(stack)
        stack.spacing = 4
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.centerY(inView: profileImageView,
                      leftAnchor: profileImageView.rightAnchor,
                      paddingLeft: 12)
        
    }
}
