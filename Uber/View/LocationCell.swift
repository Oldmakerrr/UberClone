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
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
