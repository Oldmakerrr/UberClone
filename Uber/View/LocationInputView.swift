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
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12, width: 24, height: 25)
    }
    
    //MARK: - Selectors
    
    @objc private func handleBackTapped() {
        delegate?.didComplete(self)
    }

}
