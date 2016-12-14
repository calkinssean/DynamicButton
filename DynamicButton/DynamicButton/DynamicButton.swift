//
//  DynamicButton.swift
//  DynamicButton
//
//  Created by Sean Calkins on 12/14/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

@IBDesignable class DynamicButton: UIView {
    
    enum openType {
        
        case slideUp
        case slideDown
        case popUp
        case popDown
        
    }
    
    fileprivate let tintLayer = CAShapeLayer()
    
    var highlightPath = UIBezierPath()
    var dynamicButtonDelegate: DynamicButtonDelegate!
    
    @IBInspectable var openType: openType = .slideUp
    @IBInspectable var titleColor: UIColor = .black
    @IBInspectable var originalColor: UIColor = .blue
    
    var highlightColor : UIColor!
    
    var overlayView: OverlayView!
    
    var buttonLayer: ButtonLayer?
    var currentlyHidden: Bool = true
    
    var buttonCell: ButtonCell?
    var items = [ButtonCell]()
    
    var plusColor: UIColor = .black {
        didSet {
            buttonLayer?.plusColor = plusColor
        }
    }

    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        buttonLayer = ButtonLayer.init(bgColor: self.backgroundColor!)
        originalColor = self.backgroundColor!
        self.backgroundColor = UIColor.clear
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.addSublayer(buttonLayer!)
        
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.highlightPath = UIBezierPath(roundedRect: frame, cornerRadius: max(frame.width, frame.height) / 2 )
        
    }
    
    override var intrinsicContentSize: CGSize {
        
        return CGSize(width: 55, height: 55)
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        buttonLayer?.frame = self.bounds
        self.invalidateIntrinsicContentSize()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    //   self.createTintLayer()
   
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       
       // self.tintLayer.removeFromSuperlayer()
        
        if self.currentlyHidden {
            
            self.openButton()
            
        } else {
            
            self.closeButton()
            
        }
    }
}

// MARK: - Open/Close button
extension DynamicButton {
    
    func openButton() {
        
        self.currentlyHidden = false
        self.overlayView = OverlayView()
        self.superview?.insertSubview(self.overlayView, belowSubview: self)
        
        overlayView.addTarget(self, action: #selector(DynamicButton.closeButton), for: .touchUpInside)
        
        UIView.animate(withDuration: 0.3) {
            
            self.layer.transform = CATransform3DMakeRotation(CGFloat(-M_PI_4), 0, 0, 1)
            self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            
        }
        
        for item in items {
            self.overlayView.addSubview(item)
        }
        
        switch self.openType {
        case .slideUp:
            self.slideUpAnimation(shown: true)
        case .slideDown:
            slideDownAnimation(shown: true)
        case .popUp:
            popAnimation(shown: true)
        case .popDown:
            popDownAnimation(shown: true)
        }
        
        self.dynamicButtonDelegate?.openDynamicButton?(self)
        
    }
    
    func closeButton() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layer.transform = CATransform3DMakeRotation(0, 0.0, 0.0, 1)
            self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        })
        
        
        switch self.openType {
        case .slideUp:
            slideUpAnimation(shown: false)
        case .slideDown:
            slideDownAnimation(shown: false)
        case .popUp:
            popAnimation(shown: false)
        case .popDown:
            popDownAnimation(shown: false)
        }
        
        self.dynamicButtonDelegate?.closeDynamicButton?(self)
        
    }

    
}

// MARK: - Add Buttons
extension DynamicButton {
    
    open func add(color: UIColor, title: String?, image: UIImage?, handler: @escaping ((ButtonCell) -> Void)) {
        
        let item = ButtonCell()
        item.buttonItemColor = color
        item.icon = image
        item.backgroundColor = UIColor.clear
        item.alpha = 0
        item.title = title
        item.titleColor = titleColor
        item.actionClosure = handler
        item.actionButton = self
        items.append(item)
        
    }
    
}

// MARK: - Animations
extension DynamicButton {
    
    // slide up
    
    fileprivate func slideUpAnimation(shown:Bool) {
        
        var delay = 0.0
        
        if shown {
            for (index,item) in items.enumerated() {
                
                item.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y - self.frame.height * CGFloat(index), width: self.frame.width, height: self.frame.height)
                
                UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions(), animations: {
                    let shift = self.frame.height
                   
                    item.transform = CGAffineTransform.init(translationX: 0, y:  -shift)
                    
                    item.alpha = 1
                }, completion: nil)
                delay += 0.15
            }
            
        } else {
            
            for (index,item) in items.reversed().enumerated(){
                
                UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions(), animations: {
                    item.transform = CGAffineTransform.identity
                    item.alpha = 0
                }, completion: { (finish) in
                    if index == self.items.count-1 && !shown{
                        self.currentlyHidden = true
                        self.overlayView.removeFromSuperview()
                    }
                })
                
                delay += 0.15
                
            }
        }
    }
    
    // slide down
    
    fileprivate func slideDownAnimation(shown:Bool) {
        
        var delay = 0.0
        if shown {
            for (index,item) in items.enumerated() {
                item.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.height * CGFloat(index) + 25, width: self.frame.width, height: self.frame.height)
                
                UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions(), animations: {
                    let shift = self.frame.height
                    item.transform = CGAffineTransform.init(translationX: 0, y:  shift)
                    item.alpha = 1
                }, completion: nil)
                delay += 0.15
            }
        } else {
            for (index,item) in items.reversed().enumerated(){
                
                UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions(), animations: {
                    item.transform = CGAffineTransform.identity
                    item.alpha = 0
                }, completion: { (finish) in
                    if index == self.items.count-1 && !shown{
                        self.currentlyHidden = true
                        self.overlayView.removeFromSuperview()
                    }
                })
                delay += 0.15
            }
        }
    }
    
    // pop up
    
    fileprivate func popAnimation(shown:Bool) {
        var delay = 0.0
        if shown{
            for (index,item) in items.enumerated() {
                item.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y - self.frame.height * CGFloat(index+1) , width: self.frame.width, height: self.frame.height)
                item.transform = CGAffineTransform.init(scaleX: 0.0, y: 0.0)
                UIView.animate(withDuration: 0.3, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions(), animations: {
                    item.transform = CGAffineTransform.identity
                    item.alpha = 1
                }, completion: nil)
                delay += 0.15
            }
            
        } else {
            
            for (index,item) in items.reversed().enumerated(){
                UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
                    
                    item.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
                    item.alpha = 0
                }, completion: { (finish) in
                    if index == self.items.count-1 && !shown{
                        self.currentlyHidden = true
                        self.overlayView.removeFromSuperview()
                    }
                    item.transform = CGAffineTransform.identity
                })
                delay += 0.15
            }
        }
    }
    
  
    // pop down
    
    fileprivate func popDownAnimation(shown:Bool) {
        
        var delay = 0.0
        
        if shown{
            
            for (index,item) in items.enumerated() {
                item.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.height * CGFloat(index+1) + 25, width: self.frame.width, height: self.frame.height)
                
                item.transform = CGAffineTransform.init(scaleX: 0.0, y: 0.0)
                
                UIView.animate(withDuration: 0.3, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions(), animations: {
                    item.transform = CGAffineTransform.identity
                    item.alpha = 1
                }, completion: nil)
                
                delay += 0.15
            }
            
        } else {
            
            for (index,item) in items.reversed().enumerated(){
                UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
                    
                    item.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
                    item.alpha = 0
                }, completion: { (finish) in
                    if index == self.items.count-1 && !shown{
                        self.currentlyHidden = true
                        self.overlayView.removeFromSuperview()
                    }
                    item.transform = CGAffineTransform.identity
                })
                delay += 0.15
            }
        }
    }

    
}








