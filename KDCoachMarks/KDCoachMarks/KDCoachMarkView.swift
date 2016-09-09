//
//  KDCoachMarkView.swift
//  KDCoachMarks
//
//  Created by Kedar Desai on 01/09/16.
//  Copyright © 2016 Kedar Desai. All rights reserved.
//

import UIKit

@objc protocol KDCoachMarkViewDelegate {
    
    /// Navigation Methods
    optional func coachMarkViewWillNavigate(coachMarkView: KDCoachMarkView, index: Int)
    optional func coachMarkViewDidNavigate(coachMarkView: KDCoachMarkView, index: Int)
    
    /// Cleanup Methods
    optional func coachMarkViewWillCleanup(coachMarkView: KDCoachMarkView)
    optional func coachMarkViewDidCleanup(coachMarkView: KDCoachMarkView)
    
    /// User-Action Methods
    optional func coachMarkViewDidTap(index: Int)
}

class KDCoachMarkView: UIView {
    
    /// delegate variable to navigate the control all over the project.
    var delegate: KDCoachMarkViewDelegate? = nil
    
    /// array of coachmarks
    var coachMarks: NSArray? = nil
    
    /// Specifies the duration of animation
    var animationDuration: CFTimeInterval?
    
    var maskColor: UIColor? = UIColor.clearColor() {
        didSet {
            self.mask?.fillColor = maskColor?.CGColor
        }
    }
    var cutoutRadius: CGFloat?
    var maxLblWidth: CGFloat?
    var lblSpacing: CGFloat?
    var useBubbles: Bool?
    
    var mask: CAShapeLayer?
    var markIndex: Int? = 0
    var continueLable: UILabel?
    
    /*!
     *  @author     :   Kedar Desai
     *  @desc       :   Constants for normal use
     */
    let kAnimationDuration: CFTimeInterval = 0.3
    let kCutoutRadius: CGFloat = 2.0
    let kMaxLblWidth: CGFloat = 230.0
    let kLblSpacing: CGFloat = 35.0
    
    var animatingCircle: KDCircleView?
    var bubble: KDBubble?
    
    // MARK: - UIViewLifeCycle Methods -
    
    convenience init(frame: CGRect, coachMarks: NSArray) {
        self.init(frame: frame)
        
        self.coachMarks = coachMarks
        self.setup()
    }
    
//    override convenience init(frame: CGRect) {
//        self.init(frame: frame)
//        
//        self.setup()
//    }
//    
//    required convenience init?(coder aDecoder: NSCoder) {
//        self.init(coder: aDecoder)
//        self.setup()
//    }
    
    deinit {
        self.animatingCircle = nil
        self.bubble = nil
        self.maskColor = nil
        self.coachMarks = nil
    }
    
    
    // MARK: - Initial Setting Methods -
    
    func setup() {
        
        self.animationDuration = kAnimationDuration
        self.cutoutRadius = kCutoutRadius
        self.maxLblWidth = kMaxLblWidth
        self.lblSpacing = kLblSpacing
        self.useBubbles = true
        
        // Shape Layer Mask
        self.mask = CAShapeLayer()
        mask?.fillRule = kCAFillRuleEvenOdd
        mask?.fillColor = UIColor(white: 0.0, alpha: 0.8).CGColor
        self.layer.addSublayer(mask!)
        
        // Adding Gestures
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(KDCoachMarkView.userDidTap(_:)))
        self.addGestureRecognizer(tapGesture)
        let swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(KDCoachMarkView.userDidTap(_:)))
        swipeGesture.direction = [.Left, .Right]
        self.addGestureRecognizer(swipeGesture)
        
        // Hide initial state
        self.hidden = true;
    }
    
    
    // MARK: - Cutout Modification Methods -
    
    func setCutOut(rect: CGRect, shape: KDCoachMarkShape) {
        
        // Define shape
        let maskPath: UIBezierPath = UIBezierPath(rect: self.bounds)
        var cutoutPath: UIBezierPath?
        
        switch shape {
        case .kCircle:
            cutoutPath = UIBezierPath(ovalInRect: rect)
            
        case .kSquare:
            cutoutPath = UIBezierPath(rect: rect)
            
        default:
            cutoutPath = UIBezierPath(roundedRect: rect, cornerRadius: self.cutoutRadius!)
        }
        
        maskPath.appendPath(cutoutPath!)
        
        // Set the new path
        mask?.path = maskPath.CGPath
    }
    
    
    func animateCutout(rect: CGRect, shape: KDCoachMarkShape) {
        
        // Define shape
        let maskPath: UIBezierPath = UIBezierPath(rect: self.bounds)
        var cutoutPath: UIBezierPath?
        
        switch shape {
        case .kCircle:
            cutoutPath = UIBezierPath(ovalInRect: rect)
            
        case .kSquare:
            cutoutPath = UIBezierPath(rect: rect)
            
        default:
            cutoutPath = UIBezierPath(roundedRect: rect, cornerRadius: self.cutoutRadius!)
        }
        
        maskPath.appendPath(cutoutPath!)
        
        // Animating mask
        let keyPathForAnimation: String = "keyPath"
        let animation: CABasicAnimation = CABasicAnimation(keyPath: keyPathForAnimation)
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.duration = self.animationDuration!
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.fromValue = mask?.path
        animation.toValue = mask?.path
        mask?.addAnimation(animation, forKey: keyPathForAnimation)
        mask?.path = maskPath.CGPath
    }
    
    
    // MARK: - Gesture Ation Methods -
    
    func userDidTap(gesture: UIGestureRecognizer) {
        
        if self.delegate != nil {
            if let tapMethodCalled = self.delegate!.coachMarkViewDidTap {
                self.delegate!.coachMarkViewDidTap!(markIndex!)
            }
        }
        
        self.navigateToCoachMark(markIndex! + 1)
    }
    
    
    // MARK: - Navigation Methods -
    
    func start() {
        // Fade in self
        self.alpha = 0.0
        self.hidden = false
        
        UIView.animateWithDuration(self.animationDuration!, animations: {
                self.alpha = 1.0
            }, completion: {
                (finished: Bool) in
                // Go to the first coach mark
                self.navigateToCoachMark(0)
        })
    }
    
    func navigateToCoachMark(index: Int) {
        
        // Check if out of bounds
        if index >= self.coachMarks?.count {
            self.cleanup()
            return
        }
        
        markIndex = index
        
        if self.delegate != nil {
            if let tapMethodCalled = self.delegate!.coachMarkViewWillNavigate {
                self.delegate!.coachMarkViewWillNavigate!(self, index: markIndex!)
            }
        }
        
        let coachMark: KDCoachMarkMetadata = self.coachMarks!.objectAtIndex(markIndex!) as! KDCoachMarkMetadata
        
        if self.useBubbles != nil {
            self.animateNextBubble()
        }
        
        // If first coach mark is getting shown, set the cutout to the center of the first coach mark.
        if markIndex == 0 {
            let centerPointX: CGFloat = CGFloat(floorf(Float(coachMark.rect!.origin.x + (coachMark.rect!.size.width / 2.0))))
            let centerPointY: CGFloat = CGFloat(floorf(Float(coachMark.rect!.origin.y + (coachMark.rect!.size.height / 2.0))))
            
            let center: CGPoint = CGPointMake(centerPointX, centerPointY)
            let centerZero: CGRect = CGRectMake(center.x, center.y, CGSizeZero.width, CGSizeZero.height)
            self.setCutOut(centerZero, shape: coachMark.shape!)
        }
        
        // Animate cutout
        self.animateCutout(coachMark.rect!, shape: coachMark.shape!)
        
        // Animate Swipe Gesture
        self.showSwipeAnimation()
    }
    
    
    // MARK: - Swipe Animation Methods -
    
    func showSwipeAnimation() {
        
        let coachMark: KDCoachMarkMetadata = self.coachMarks?.objectAtIndex(markIndex!) as! KDCoachMarkMetadata
        
        
        // If coachmark doesn't need swipe animation. Remove it if already exists.
        if self.animatingCircle != nil {
            UIView.animateWithDuration(0.6, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.animatingCircle!.alpha = 0.0
                }, completion: { (finished: Bool) in
                    self.animatingCircle!.removeFromSuperview()
                    
                    // Create another swipe animation circle view.
                    if coachMark.isSwipeEnabled! {
                        self.animatingCircle = KDCircleView.init(frame: self.frame)
                        self.animatingCircle!.swipeDirection = coachMark.swipeDirection!
                        
                        if self.subviews.contains(self.animatingCircle!) == false {
                            self.addSubview(self.animatingCircle!)
                        }
                        
                        self.animatingCircle!.swipeInFrame(coachMark.rect!)
                    }
            })
            
        } else {
            // Create another swipe animation circle view.
            if coachMark.isSwipeEnabled! {
                self.animatingCircle = KDCircleView.init(frame: self.frame)
                self.animatingCircle!.swipeDirection = coachMark.swipeDirection!
                
                if self.subviews.contains(self.animatingCircle!) == false {
                    self.addSubview(self.animatingCircle!)
                }
                
                self.animatingCircle!.swipeInFrame(coachMark.rect!)
            }
        }
    }
    
    
    // MARK: - Bubble Caption Methods -
    
    func animateNextBubble() {
        
        // Get current coach mark information
        let coachMark: KDCoachMarkMetadata = self.coachMarks!.objectAtIndex(markIndex!) as! KDCoachMarkMetadata
        
        // Removing previous bubble
        if self.bubble != nil {
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { 
                    self.bubble!.alpha = 0.0
                }, completion: nil)
        }
        
        // If there is no caption for coachmark return
        if coachMark.caption?.characters.count == 0 {
            return
        }
        
        // Create a new bubble
        // If using point of interest(poi) frame use that instead of cutout frame otherwise use cutout frame.
        if coachMark.poi != nil {
            if CGRectIsEmpty(coachMark.poi!) == true {
                self.bubble = KDBubble(frame: coachMark.rect!, bubbleTitle: coachMark.caption!, description: nil, arrowPosition: KDBubbleArrowPosition.kTop, color: nil, font: coachMark.font!)
                
            } else {
                self.bubble = KDBubble(frame: coachMark.poi!, bubbleTitle: coachMark.caption!, description: nil, arrowPosition: KDBubbleArrowPosition.kTop, color: nil, font: coachMark.font!)
            }
            
        } else {
            self.bubble = KDBubble(frame: coachMark.rect!, bubbleTitle: coachMark.caption!, description: nil, arrowPosition: KDBubbleArrowPosition.kTop, color: nil, font: coachMark.font!)
        }
        
        
        self.bubble!.alpha = 0.0
        self.addSubview(self.bubble!)
        
        // Fade in & bounce animation
        UIView.animateWithDuration(0.8, delay: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: { 
                self.bubble!.alpha = 1.0
                self.bubble?.animate()
            }, completion: nil)
    }
    
    
    // MARK: - Cleanup Methods
    
    func cleanup() {
        
        if self.delegate != nil {
            if let willCleanupMethod = self.delegate?.coachMarkViewWillCleanup {
                self.delegate!.coachMarkViewWillCleanup!(self)
            }
        }
        
        // Animate & remove from super view
        UIView.animateWithDuration(0.6, delay: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.alpha = 0.0
                self.animatingCircle?.alpha = 0.0
                self.bubble?.alpha = 0.0
            
            }, completion: {
                (finished: Bool) in
                
                self.animatingCircle?.animationShouldStop = true
                self.bubble?.shouldAnimationStop = true
                self.animatingCircle?.removeFromSuperview()
                self.bubble?.removeFromSuperview()
                self.removeFromSuperview()
        })
        
        
        if self.delegate != nil {
            if let didCleanupMethod = self.delegate?.coachMarkViewDidCleanup {
                self.delegate!.coachMarkViewDidCleanup!(self)
            }
        }
    }
    
    
    // MARK: - Animation Delegate Methods
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        if self.delegate != nil {
            if let didCleanupMethod = self.delegate?.coachMarkViewDidNavigate {
                self.delegate!.coachMarkViewDidNavigate!(self, index: markIndex!)
            }
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
