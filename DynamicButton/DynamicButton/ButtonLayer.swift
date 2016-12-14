//
//  ButtonLayer.swift
//  DynamicButton
//
//  Created by Sean Calkins on 12/14/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

class ButtonLayer: CAShapeLayer {
    
    convenience init(bgColor: UIColor) {
        
        self.init()
        self.backgroundColor = bgColor.cgColor
        self.circleMask()
        
    }
    
    var plusColor: UIColor = .black {
        didSet {
            self.strokeColor = plusColor.cgColor
        }
    }
    
    override var frame: CGRect {
        didSet {
            self.drawPlusSign()
            self.circleMask()
        }
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

extension ButtonLayer {

    fileprivate func drawPlusSign() {
        
        let rect = self.frame
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: 15.0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - 15.0))
        path.move(to: CGPoint(x: 15, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - 15, y: rect.midY))
        self.lineWidth = 3
        self.lineCap = kCALineCapRound
        self.path = path.cgPath
        
    }
    
    
    fileprivate func circleMask() {
        
        let rect = self.frame
        let circlePath = UIBezierPath(roundedRect:
            CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
            , cornerRadius: rect.width)
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.black.cgColor
        self.mask = circleLayer
        
    }
    
    
    
}

import UIKit

class OverlayView: UIControl {
    
    
    init() {
        super.init(frame: CGRect.zero)
        self.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.black.withAlphaComponent(0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

// MARK:- UIColorExtension
extension UIColor {
    
    var reded : CGFloat {
        get {
            let components = self.cgColor.components
            return components![0]
        }
    }
    
    var greened : CGFloat{
        get {
            let components = self.cgColor.components
            return components![1]
        }
    }
    
    var blued : CGFloat{
        get {
            let components = self.cgColor.components
            return components![2]
        }
    }
    
    
    var alpha : CGFloat{
        get{
            return self.cgColor.alpha
        }
    }
    
    func alpha(alpha: CGFloat) -> UIColor {
        return UIColor(red: self.reded, green: self.greened, blue: self.blued, alpha: alpha)
    }
    
    func white(rate: CGFloat) -> UIColor {
        return UIColor(
            red: self.reded + (1.0 - self.reded) * rate,
            green: self.greened + (1.0 - self.greened) * rate,
            blue: self.blued + (1.0 - self.blued) * rate,
            alpha: 1.0
        )
    }
    
}

