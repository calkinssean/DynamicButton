//
//  ButtonCell.swift
//  DynamicButton
//
//  Created by Sean Calkins on 12/14/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

class ButtonCell: UIView {
    
    public init(){
        super.init(frame:CGRect.zero)
        self.createCircle()
        self.createShadow()
        self.createLabelShadow()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    weak var actionButton: DynamicButton!
    
    fileprivate let circleLayer = CAShapeLayer()
    fileprivate let tintLayer = CAShapeLayer()
   
    let circlePath = UIBezierPath(roundedRect: CGRect(x: 16, y: 0, width: 46, height: 46), cornerRadius: 20)
    
    var actionClosure: ((ButtonCell) -> Void)?
    
    var originalColor: UIColor?
    
    open var buttonItemColor: UIColor = .clear {
        didSet {
            
            circleLayer.fillColor = buttonItemColor.cgColor
            originalColor = buttonItemColor
            
        }
    }
    
    open var titleColor: UIColor = .white{
        didSet {
            
            titleLabel.textColor = titleColor
            
        }
        
    }
    
    var _titleLabel: UILabel? = nil
    
    open var titleLabel: UILabel {
        get {
            if _titleLabel == nil {
                _titleLabel = UILabel()
                _titleLabel?.textColor = titleColor
                addSubview(_titleLabel!)
            }
            return _titleLabel!
        }
    }

    open var title: String? = nil {
        
        didSet {
            titleLabel.text = title
            titleLabel.sizeToFit()
            titleLabel.frame.origin.x = -titleLabel.frame.size.width
            titleLabel.frame.origin.y = 21 - titleLabel.frame.size.height / 2
        }
        
    }
    
    var _iconImageView: UIImageView? = nil
    open var iconImageView: UIImageView {
        get {
            if _iconImageView == nil {
                _iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                _iconImageView?.contentMode = UIViewContentMode.scaleAspectFill
                addSubview(_iconImageView!)
            }
            return _iconImageView!
        }
    }
    
    open var icon: UIImage? = nil {
        didSet {
            iconImageView.image = icon
        }
    }
    
    override var frame: CGRect {
        didSet {
            _iconImageView?.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 3.2)
        }
    }
    

    fileprivate func createCircle() {
        
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = buttonItemColor.cgColor
        originalColor = buttonItemColor
        layer.addSublayer(circleLayer)
        
    }
    
    fileprivate func createLayer() {
        
        tintLayer.path = circlePath.cgPath
        tintLayer.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor
        layer.addSublayer(tintLayer)
        
    }
    
    fileprivate func createShadow() {
        circleLayer.shadowOffset = CGSize(width: 0, height: 0)
        circleLayer.shadowOpacity = 1
    }
    
    fileprivate func createLabelShadow() {
        titleLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        titleLabel.layer.shadowRadius = 2
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOpacity = 0.5
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.createLayer()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        tintLayer.removeFromSuperlayer()
        if let touch = touches.first {
            if touch.tapCount == 1 {
                actionClosure?(self)
                actionButton!.closeButton()
            }
        }
        circleLayer.fillColor = originalColor?.cgColor
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
