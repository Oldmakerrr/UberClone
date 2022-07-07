//
//  CircularProgressView.swift
//  Uber
//
//  Created by Apple on 07.07.2022.
//

import UIKit

class CircularProgressView: UIView {
    
    //MARK: - Properties
    
    var progressLayer: CAShapeLayer!
    var trackLayer: CAShapeLayer!
    var pulsatingLayer: CAShapeLayer!
    
    
    //MARK: - Lyfecicle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCircleLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper Function
    
    private func configureCircleLayers() {
        pulsatingLayer = circleSapeLayer(strockColor: .clear, fillColor: .blue)
        layer.addSublayer(pulsatingLayer)
        
        trackLayer = circleSapeLayer(strockColor: .clear, fillColor: .clear)
        layer.addSublayer(trackLayer)
        trackLayer.strokeEnd = 1
        
        progressLayer = circleSapeLayer(strockColor: .systemPink, fillColor: .clear)
        layer.addSublayer(progressLayer)
        progressLayer.strokeEnd = 1
    }
    
    private func circleSapeLayer(strockColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let center = CGPoint(x: 0, y: 32)
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: self.frame.width / 2.5,
                                        startAngle: -(.pi / 2), endAngle: 1.5 * .pi,
                                        clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strockColor.cgColor
        layer.lineWidth = 12
        layer.fillColor = fillColor.cgColor
        layer.lineCap = .round
        layer.position = self.center
        return layer
    }
    
}
