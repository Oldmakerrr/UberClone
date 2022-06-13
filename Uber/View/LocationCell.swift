//
//  LocationCell.swift
//  Uber
//
//  Created by Apple on 13.06.2022.
//

import UIKit

protocol ReusableView: AnyObject {
    static var identifier: String { get }
}

class LocationCell: UITableViewCell, ReusableView {
    
    //MARK: - Properties
    
    static var identifier: String {
        String(describing: self)
    }
    
    private let titelLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Title"
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Adress"
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let stackView = UIStackView(arrangedSubviews: [titelLabel, addressLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        addSubview(stackView)
        stackView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
    }
    
}
