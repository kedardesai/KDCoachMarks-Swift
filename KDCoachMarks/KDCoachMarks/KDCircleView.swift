//
//  KDCircleView.swift
//  KDCoachMarks
//
//  Created by Kedar Desai on 01/09/16.
//  Copyright © 2016 Kedar Desai. All rights reserved.
//

import UIKit

class KDCircleView: UIView {
    
    /// stops animations
    var animationShouldStop: Bool? = false
    
    /// Sets the direction of swipe
    var swipeDirection: KDCoachMarkSwipeDirection? = .kLeftSwipe
    
    var circleViewHeight: CGFloat = 40
    var circleViewWidth: CGFloat = 40
    var swipeAreaMargin: CGFloat = 20
    var swipingFrame: CGRect?
    
    
    
    // MARK: - Class Overridden Methods -
    
    override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
    
    
    // MARK: - UIViewLifeCycle Methods -
    
    override init(frame: CGRect) {
        
        super.init(frame: CGRectMake(10, 0, circleViewWidth, circleViewHeight))
        
        self.backgroundColor = UIColor.clearColor()
        
        let shapeLayer: CAShapeLayer = self.layer as! CAShapeLayer
        shapeLayer.path = UIBezierPath(ovalInRect: CGRectMake(0, 0, circleViewWidth, circleViewHeight)).CGPath
        shapeLayer.fillColor = UIColor(white: 1.0, alpha: 1.0).CGColor
        shapeLayer.shadowRadius = 8.0
        shapeLayer.shadowOffset = CGSizeMake(0, 0)
        shapeLayer.shadowColor = UIColor(red: 0.0, green: 0.299, blue: 0.714, alpha: 1.0).CGColor
        shapeLayer.shadowOpacity = 1.0
        shapeLayer.shadowPath = UIBezierPath(ovalInRect: CGRectMake(0, 0, circleViewWidth, circleViewHeight)).CGPath
        
        self.animationShouldStop = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Positioning Methods -
    
    func swipeInFrame(frame: CGRect) {
        swipingFrame = frame
        self.centerInView(self, frame: frame)
        self.animateSwipe()
    }
    
    func centerYPositionInView(view: UIView, frame: CGRect) {
        
        switch self.swipeDirection! {
        case .kRightSwipe:
            let centerY = frame.origin.y + CGRectGetHeight(frame)/2
            let offsetY = CGRectGetHeight(view.frame)/2
            
            let newY = centerY - offsetY
            view.frame = CGRectMake(view.frame.origin.x, newY, circleViewWidth, circleViewHeight)
            
        case .kLeftSwipe:
            let centerY = frame.origin.y + CGRectGetHeight(frame)/2
            let offsetY = CGRectGetHeight(view.frame)/2
            
            let newY = centerY - offsetY
            view.frame = CGRectMake(view.frame.origin.x, newY, circleViewWidth, circleViewHeight)
            
        case .kUpSwipe:
            let newY = CGRectGetHeight(frame) - swipeAreaMargin*2
            view.frame = CGRectMake(view.frame.origin.x, newY, circleViewWidth, circleViewHeight)
            
        default: // .kDownSwipe
            let newY = swipeAreaMargin
            view.frame = CGRectMake(view.frame.origin.x, newY, circleViewWidth, circleViewHeight)
        }
    }
    
    func centerXPositionInView(view: UIView, frame: CGRect) {
        
        switch self.swipeDirection! {
        case .kRightSwipe:
            let newY = CGRectGetWidth(view.frame) - swipeAreaMargin*2
            view.frame = CGRectMake(view.frame.origin.x, newY, circleViewWidth, circleViewHeight)
            
        case .kLeftSwipe:
            let newY = swipeAreaMargin
            view.frame = CGRectMake(view.frame.origin.x, newY, circleViewWidth, circleViewHeight)
            
        case .kUpSwipe:
            let centerX: CGFloat = frame.origin.x + CGRectGetWidth(frame)/2
            let offSetX: CGFloat = CGRectGetWidth(view.frame) / 2
            
            let newX: CGFloat = centerX - offSetX
            view.frame = CGRectMake(newX, view.frame.origin.y, circleViewWidth, circleViewHeight)
            
        default: // .kDownSwipe
            let centerX: CGFloat = frame.origin.x + CGRectGetWidth(frame)/2
            let offSetX: CGFloat = CGRectGetWidth(view.frame) / 2
            
            let newX: CGFloat = centerX - offSetX
            view.frame = CGRectMake(newX, view.frame.origin.y, circleViewWidth, circleViewHeight)
        }
    }
    
    func centerInView(view: UIView, frame: CGRect) {
        self.centerXPositionInView(view, frame: frame)
        self.centerYPositionInView(view, frame: frame)
    }
    
    
    // MARK: - Gesture Recognizer Action Methods -
    
    func userTap(gestureRecognizer: UIGestureRecognizer) {
        self.hidden = true
        self.removeFromSuperview()
    }
    
    
    // MARK: - Animation Methods -
    
    func animateSwipe() {
        if (self.animationShouldStop == false) {
            let scale: CGAffineTransform = CGAffineTransformMakeScale(2, 2)
            
            let translateRightToValue: CGFloat = swipingFrame!.size.width - (swipeAreaMargin*2) - circleViewWidth
            let translateUpToValue: CGFloat = -(swipingFrame!.size.height - swipeAreaMargin*2 - circleViewHeight)
            let translateDownToValue: CGFloat = (swipingFrame!.size.height - swipeAreaMargin*2) - circleViewHeight
            
            let translateRight: CGAffineTransform = CGAffineTransformMakeTranslation(translateRightToValue, 0)
            let translateUp: CGAffineTransform = CGAffineTransformMakeTranslation(0, translateUpToValue)
            let translateDown: CGAffineTransform = CGAffineTransformMakeTranslation(0, translateDownToValue)
            
            switch self.swipeDirection! {
            case .kLeftSwipe:
                self.transform = scale
                
            case .kRightSwipe:
                // Start on the right hand side as well as scaling
                self.transform = CGAffineTransformConcat(translateRight, scale)
                
            case .kUpSwipe:
                // Start on the right hand side as well as scaling
                self.transform = CGAffineTransformConcat(translateUp, scale)
                
            default: // .kDownSwipe
                // Start on the right hand side as well as scaling
                self.transform = CGAffineTransformConcat(translateDown, scale)
            }
            
            self.alpha = 0.0
            
            UIView.animateWithDuration(0.6, delay: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    // Fade In
                    switch self.swipeDirection! {
                    case .kLeftSwipe:
                        // Scale down to the normal
                        self.transform = CGAffineTransformMakeScale(1, 1)
                        
                    case .kRightSwipe:
                        // Start on the right hand side
                        self.transform = translateRight
                        
                    case .kUpSwipe:
                        // Start on the up side
                        self.transform = translateUp
                        
                    default:
                        // Start on the down side
                        self.transform = translateDown
                    }
                    self.alpha = 1.0
                
                }, completion: { (finished: Bool) in
                    UIView.animateWithDuration(1.0, animations: { 
                            switch self.swipeDirection! {
                            case .kLeftSwipe:
                                // Slide Right
                                self.transform = translateRight
                                
                            case .kRightSwipe:
                                // Slide Right
                                self.transform = CGAffineTransformIdentity
                                
                            case .kUpSwipe:
                                // Slide Up
                                self.transform = CGAffineTransformIdentity
                                
                            default: // .kDownSwipe
                                // Slide bottom
                                self.transform = CGAffineTransformIdentity
                            }
                            // Fade Out
                            self.alpha = 0.0
                        
                        }, completion: { (finished: Bool) in
                            self.performSelector(#selector(KDCircleView.animateSwipe))
                    })
            })
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
