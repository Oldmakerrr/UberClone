//
//  RideActionView.swift
//  Uber
//
//  Created by Apple on 22.06.2022.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: AnyObject {
    func uploadTrip(_ rideActionView: RideActionView)
    func cancelTrip(_ rideActionView: RideActionView)
    func pickupPassenger(_ rideActionView: RideActionView)
    func dropOffPassenger(_ rideActionView: RideActionView)
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case driverArrived
    case pickupPassenger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum RideActionButtonConfig: CustomStringConvertible {
    case requestRide
    case cancel
    case getDirection
    case pickup
    case dropOff
    
    var description: String {
        switch self {
        case .requestRide:
            return "CONFIRM UBERX"
        case .cancel:
            return "CANCEL"
        case .getDirection:
            return "GET DIRECTION"
        case .pickup:
            return "PICKUP PASSENGER"
        case .dropOff:
            return "DROP OFF PASSENGER"
        }
    }
    
    init() {
        self = .requestRide
    }
}

class RideActionView: UIView {
    
    var config = RideActionViewConfiguration() {
        didSet { configureUI(withConfig: config)}
    }
    private var buttonActionConfig = RideActionButtonConfig() {
        didSet{
            actionButton.setTitle(buttonActionConfig.description, for: .normal)
        }
    }
    
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    var user: User?
    
    weak var delegate: RideActionViewDelegate?
    
    //MARK: - Properies
    
    let typeOfUber: String
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        return view
    }()
    
    private lazy var infoViewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 30)
        label.text = typeOfUber.uppercased()
        return label
    }()
    
    private lazy var typeOfUberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.text = "Uber\(typeOfUber.uppercased())"
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("CONFIRM UBER\(typeOfUber.uppercased())", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(buttonActionPressed), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        return button
    }()
    
    //MARK: - Lifecycle
    
    init(typeOfUber: String = "x") {
        self.typeOfUber = typeOfUber
        super.init(frame: .zero)
        configure()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16)
        infoView.setDimensions(height: 60)
        infoView.layer.cornerRadius = 60 / 2
        
        addSubview(typeOfUberLabel)
        typeOfUberLabel.centerX(inView: self)
        typeOfUberLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        
        separator(upView: typeOfUberLabel, paddingTop: 4)
        
        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 12, paddingBottom: 24, paddinRight: 12, height: 50)
    }
    
    private func configure() {
        backgroundColor = .white
        layer.applyShadow()
    }
    
    @objc private func buttonActionPressed() {
        switch buttonActionConfig {
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            delegate?.cancelTrip(self)
        case .getDirection:
            print("DEBUG: Handle get directions..")
        case .pickup:
            delegate?.pickupPassenger(self)
        case .dropOff:
            delegate?.dropOffPassenger(self)
        }
        
    }
    
    //MARK: - Helper function
    
    private func configureUI(withConfig config: RideActionViewConfiguration?) {
        actionButton.isEnabled = true
        guard let config = config else { return }
        switch config {
        case .requestRide:
            buttonActionConfig = .requestRide
            typeOfUberLabel.text = "Uber\(typeOfUber.uppercased())"
        case .tripAccepted:
            guard let user = user else { return }
            switch user.accountType {
            case .passenger:
                buttonActionConfig = .getDirection
                titleLabel.text = "En route to passenger"
            case .driver:
                buttonActionConfig = .cancel
                titleLabel.text = "Driver en route"
            }
            infoViewLabel.text = String(user.fullname.first ?? "X")
            typeOfUberLabel.text = user.fullname
        case .driverArrived:
            guard let user = user else { return }
            switch user.accountType {
            case .passenger:
                break
            case .driver:
                titleLabel.text = "Driver Has Arrived"
                addressLabel.text = "Please meet driver at pickup location"
            }
        case .pickupPassenger:
            titleLabel.text = "Arrived At Passenger Location"
            buttonActionConfig = .pickup
        case .tripInProgress:
            guard let user = user else { return }
            switch user.accountType {
            case .passenger:
                buttonActionConfig = .getDirection
            case .driver:
                actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                actionButton.isEnabled = false
            }
            titleLabel.text = "En Route To Destination"
        case .endTrip:
            guard let user = user else { return }
            switch user.accountType {
            case .passenger:
                buttonActionConfig = .dropOff
            case .driver:
                actionButton.setTitle("ARRIVED AT DESTINATION", for: .normal)
                actionButton.isEnabled = false
            }
        }
    }
}
