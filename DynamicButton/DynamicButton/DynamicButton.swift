//
//  DynamicButton.swift
//  DynamicButton
//
//  Created by Sean Calkins on 12/14/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

@objc protocol DynamicButtonDelegate {
    
    @objc optional func openDynamicButton(_ button: DynamicButton)
    @objc optional func closeDynamicButton(_ button: DynamicButton)
    
}

// MARK: - Button
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

// MARK: - Button Layer
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


// MARK: - Overlay View
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


// MARK: - Button Cell
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







