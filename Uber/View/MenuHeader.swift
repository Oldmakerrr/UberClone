//
//  MenuHeader.swift
//  Uber
//
//  Created by Apple on 29.06.2022.
//

import UIKit

class MenuHeader: UIView {
    
    //MARK: - Properties
    
    var user: User? {
        didSet {
            fullNameLabel.text = user?.fullname
            emailLabel.text = user?.email
        }
    }
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.text = "Full name"
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "test@gmail.com"
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backGroundColor
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper Functions
    
    private func setupView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor,
                                paddingTop: 4, paddingLeft: 12  ,
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
