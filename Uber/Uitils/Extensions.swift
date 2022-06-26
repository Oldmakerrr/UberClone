//
//  Extensions.swift
//  Uber
//
//  Created by Apple on 21.05.2022.
//

import UIKit
import MapKit

extension UIButton {
    
    func accountButton(message: String, title: String) {
        
        let attributeTitle = NSMutableAttributedString(string: message, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributeTitle.append(NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        
        setAttributedTitle(attributeTitle, for: .normal)
    }
    
}

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let backGroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
    static let mainBlueTint = UIColor.rgb(red: 17, green: 154, blue: 237)
}

//MARK: UIView

extension UIView {
    
    func separator(upView: UIView, paddingTop: CGFloat = 0, paddingLeft: CGFloat = 0, paddinRight: CGFloat = 0, height: CGFloat = 0.75) {
        let separator = UIView()
        separator.backgroundColor = .lightGray
        addSubview(separator)
        separator.anchor(top: upView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: paddingTop, paddingLeft: paddingLeft, paddinRight: paddinRight, height: height)
    }
    
    func inputContainerView(image: UIImage?, textField: UITextField? = nil,
                            segmentedController: UISegmentedControl? = nil) -> UIView {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.alpha = 0.87
        imageView.tintColor = .white
        view.addSubview(imageView)
        
        if let textField = textField {
            view.addSubview(textField)
            
            imageView.centerY(inView: view)
            imageView.anchor(left: view.leftAnchor, paddingLeft: 8, width: 24, height: 24)
            
            textField.centerY(inView: view)
            textField.anchor(left: imageView.rightAnchor, bottom: view.bottomAnchor,
                                  right: view.rightAnchor, paddingLeft: 8, paddingBottom: 8)
        }
        
        if let segmentedController = segmentedController {
            imageView.anchor(top: view.topAnchor, left: view.leftAnchor, paddingLeft: 8, width: 24, height: 24)
            view.addSubview(segmentedController)
            segmentedController.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 8, paddinRight: 8)
            segmentedController.centerY(inView: view, constant: 8)
        }
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        view.addSubview(separatorView)
        separatorView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor,
                             right: view.rightAnchor, paddingLeft: 8, height: 0.75)
        return view
    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddinRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddinRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
    }
    
    func centerX(inView view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constant).isActive = true
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        if let leftAnchor = leftAnchor {
            anchor(left: leftAnchor, paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        } else {
            widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        }
    }
}

//MARK: UIImage

extension UIImage {
    
    
    static func localImage(_ name: String, template: Bool = false) -> UIImage? {
        if var image = UIImage(named: name) {
            if template {
                image = image.withRenderingMode(.alwaysTemplate)
            }
            return image
        } else {
            return nil
        }
        
    }


}

//MARK: UITextField

extension UITextField {
    
    func textField(withPlaceholder placeholder: String, isSecureTextEntry: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .white
        textField.keyboardAppearance = .dark
        textField.isSecureTextEntry = isSecureTextEntry
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        return textField
    }
}

extension CALayer {
    
    func applyShadow() {
        shadowColor = UIColor.black.cgColor
        shadowOpacity = 0.55
        shadowOffset = CGSize(width: 0.5, height: 0.5)
        masksToBounds = false
    }
}

extension MKPlacemark {
    
    var address: String? {
        get {
            guard let subThoroughfare = subThoroughfare,
                  let thoroughfare = thoroughfare,
                  let locality = locality,
                  let administrativeArea = administrativeArea else { return nil }
            return "\(subThoroughfare) \(thoroughfare), \(locality), \(administrativeArea)"
        }
    }
}

//MARK: MapView

extension MKMapView {
    
    func zoomToFit(annotations: [MKAnnotation]) {
        let bottomInset = UIScreen.main.bounds.height * 0.4
        var zoomRect = MKMapRect.null
        annotations.forEach { annotation in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y,
                                      width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        let insets = UIEdgeInsets(top: 50, left: 50, bottom: bottomInset + 50, right: 50)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
}


//MARK: - ViewController

extension UIViewController {
    
    func presentAlertControlle(withTitle title: String?, withMessage message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
    
    func shouldPresentLoadingView(_ present: Bool, message: String? = nil) {
        if present {
            let view = UIView()
            view.frame = self.view.frame
            view.backgroundColor = .black
            view.alpha = 0.7
            view.tag = 1
            
            let indicator = UIActivityIndicatorView()
            indicator.style = .large
            indicator.center = view.center
            
            let label = UILabel()
            label.text = message
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = .white
            label.textAlignment = .center
            label.alpha = 0.87
            
            self.view.addSubview(view)
            view.addSubview(indicator)
            view.addSubview(label)
            
            label.centerX(inView: view)
            label.anchor(top: indicator.bottomAnchor, paddingTop: 32)
            indicator.startAnimating()
            
            UIView.animate(withDuration: 0.2) {
                view.alpha = 0.7
            }
        } else {
            view.subviews.forEach { view in
                if view.tag == 1 {
                    UIView.animate(withDuration: 0.2) {
                        view.alpha = 0
                    } completion: { _ in
                        view.removeFromSuperview()
                    }
                }
            }
        }
    }
}
