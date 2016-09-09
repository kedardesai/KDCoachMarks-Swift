//
//  KDBubble.swift
//  KDCoachMarks
//
//  Created by Kedar Desai on 01/09/16.
//  Copyright © 2016 Kedar Desai. All rights reserved.
//

import UIKit

enum KDBubbleArrowPosition {
    case kTop
    case KBottom
    case kRight
    case kLeft
}

class KDBubble: UIView {
    
    /// Defines the arrow position of bubble
    var bubblePosition: KDBubbleArrowPosition? = KDBubbleArrowPosition.kTop
    
    /// Defines view that has been attached
    var attachedView: UIView?
    
    /// Defines title of bubble.
    var bubbleTitle: NSString?
    
    /// Defines description of the bubble
    var bubbleDescription: NSString?
    
    /// Defines color of the bubble, by default it is set to UIColor.whiteColor()
    var bubbleColor: UIColor?
    
    /// Defines the frame of attacked rectangle
    var attachedFrame: CGRect?
    
    /// Defines whether bouncing should be enabled or not
    var isBouncingEnabled: Bool?
    
    /// Defines whether animation should stop or not
    var shouldAnimationStop: Bool?
    
    /// Defines the font for bubble caption and title.
    var bubbleTextFont: UIFont?
    
    
    /*!
     *  @author     :   Kedar Desai
     *  @desc       :   Constants.
     */
    let defaultFont: UIFont = UIFont(name: "HelveticaNeue", size: 14.0)!
    let defaultColor: UIColor = UIColor.whiteColor()
    
    /// Defines the space between arrow and highlighted region
    let arrowSpace: CGFloat = 6.0
    
    let arrowSize: CGFloat = 8.0
    
    /// Defines the padding between text and border of bubble
    let bubblePadding: CGFloat = 8.0
    
    let bubbleRadius: CGFloat = 6.0
    let bubbleTextColor: UIColor = UIColor.blackColor()
    var arrowOffset: CGFloat? = 0.0
    
    
    // MARK: - UIViewLifeCycle Methods -
    
    /*!
     *  @author     :   Kedar Desai
     *  @desc       :   This methods initializes this view with default values or values passed in method call.
     *  @param      :   attachedView, title, description, arrow position and color.
     *  @return     :   self object
     */
    convenience init(attachedView: UIView?, bubbleTitle: NSString?, description: NSString?, arrowPosition: KDBubbleArrowPosition?, color: UIColor?) {
        
        self.init(frame: attachedView!.frame, bubbleTitle: bubbleTitle!, description: description!, arrowPosition: arrowPosition!, color: color!)
        
    }
    
    
    /*!
     *  @author     :   Kedar Desai
     *  @desc       :   This methods initializes this view with default values or values passed in method call.
     *  @param      :   frame, title, description, arrow position and color.
     *  @return     :   self object
     */
    convenience init(frame: CGRect?, bubbleTitle: NSString?, description: NSString?, arrowPosition: KDBubbleArrowPosition?, color: UIColor?) {
        
        self.init(frame: frame!, bubbleTitle: bubbleTitle!, description: description!, arrowPosition: arrowPosition!, color: color!)
    }
    
    
    /*!
     *  @author     :   Kedar Desai
     *  @desc       :   This methods initializes this view with default values or values passed in method call.
     *  @param      :   frame, title, description, arrow position, color and font.
     *  @return     :   self object
     */
    convenience init(frame: CGRect?, bubbleTitle: NSString?, description: NSString?, arrowPosition: KDBubbleArrowPosition?, color: UIColor?, font: UIFont?) {
        
        self.init()
        
        self.bubbleColor = (color != nil) ? color! : defaultColor
        self.bubbleTextFont = (font != nil) ? font : defaultFont
        self.attachedFrame = frame
        self.bubbleTitle = bubbleTitle
        self.bubbleDescription = description
        self.bubblePosition = arrowPosition
        self.backgroundColor = UIColor.clearColor()
        
        // Positioning the bubble.
        self.frame = self.calculateFrameWithFont(self.bubbleTextFont!)
        self.fixFrameIfOutOfBounds()
        
        self.userInteractionEnabled = false
        
        // Calculate and position text
        let offset = self.offsets()
        let x = offset.width + (bubblePadding * 1.5)
        let y = offset.height + (bubblePadding * 1.25)
        let width = self.frame.size.width - x - (bubblePadding * 1.5)
        let height = self.frame.size.height - y - (bubblePadding * 1.25)
        
        // Adding a title label
        let titleLabel = UILabel(frame: CGRectMake(x, y, width, height))
        titleLabel.font = self.bubbleTextFont
        titleLabel.textColor = self.bubbleTextColor
        titleLabel.alpha = 0.9
        titleLabel.text = self.bubbleTitle! as String
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.userInteractionEnabled = false
        self.addSubview(titleLabel)
        
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        
        let ctx: CGContextRef? = UIGraphicsGetCurrentContext()
        CGContextSaveGState(ctx!)
        
        let size = self.sizeWithFont(self.bubbleTextFont!)
        
        let clippath: CGPathRef = UIBezierPath(roundedRect: CGRectMake(self.offsets().width, self.offsets().height, size.width, size.height), cornerRadius: self.bubbleRadius).CGPath
        CGContextAddPath(ctx, clippath)
        
        CGContextSetFillColorWithColor(ctx, self.bubbleColor?.CGColor)
        
        CGContextClosePath(ctx)
        CGContextFillPath(ctx)
        
        self.bubbleColor?.set()
        
        // The tip of arrow needs to be centered under the highlighted region. And this centered area is always arrow size divided by 2
        let center: CGFloat = self.arrowSize / 2
        
        // Points used to draw arrow
        // Wide Arrow -> x = center + - arrowSize
        // Skinny Arrow -> x = center + - center
        // Normal Arrow ->
        
        let startPoint: CGPoint = CGPointMake(center - self.arrowSize, self.arrowSize)
        let midPoint: CGPoint = CGPointMake(center, 0)
        let endPoint: CGPoint = CGPointMake(center + self.arrowSize, self.arrowSize)
        
        
        let path = UIBezierPath()
        path.moveToPoint(startPoint)
        path.addLineToPoint(endPoint)
        path.addLineToPoint(midPoint)
        path.addLineToPoint(startPoint)
        
        
        switch self.bubblePosition! {
        case KDBubbleArrowPosition.kTop:
            let trans: CGAffineTransform = CGAffineTransformMakeTranslation(((size.width / 2) - (self.arrowSize / 2) + self.arrowOffset!), 0)
            path.applyTransform(trans)
            
        case KDBubbleArrowPosition.KBottom:
            let rotation: CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            let trans: CGAffineTransform = CGAffineTransformMakeTranslation(((size.width/2) + (self.arrowSize/2) + self.arrowOffset!), size.height + self.arrowSize)
            path.applyTransform(rotation)
            path.applyTransform(trans)
            
        case KDBubbleArrowPosition.kLeft:
            let rotation: CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(M_PI*1.5))
            let trans: CGAffineTransform = CGAffineTransformMakeTranslation(0, (size.height + self.arrowSize)/2)
            path.applyTransform(rotation)
            path.applyTransform(trans)
            
        default: // KDBubbleArrowPosition.kRight
            let rotation: CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(M_PI*0.5))
            let trans: CGAffineTransform = CGAffineTransformMakeTranslation((size.width + self.arrowSize), (size.height-self.arrowSize)/2)
            path.applyTransform(rotation)
            path.applyTransform(trans)
        }
        
        // Implicitly does a line between p4 and p1
        path.closePath()
        
        // If you want it filled, or...
        path.fill()
        
        // If you want to draw the outline.
        path.stroke()
        
        CGContextRestoreGState(ctx)
    }
    
    
    // MARK: - Positioning and Sizing Methods -
    
    /*!
     *  @author     :   Kedar Desai
     *  @desc       :   Check if bubble is going off the screen using the position and size. If it is, return YES.
     */
    func fixFrameIfOutOfBounds() {
        
        let window = UIApplication.sharedApplication().keyWindow!.frame
        
        let xBounds = window.size.width
        let yBounds = window.size.height
        
        var x = self.frame.origin.x
        var y = self.frame.origin.y
        let width = self.frame.size.width
        var height = self.frame.size.height
        
        let padding: CGFloat = 3.0
        
        // Checking right most bound
        if ((x + width) > xBounds) {
            self.arrowOffset = (x + width) - xBounds
            x = xBounds - width
        }
        
        // Checking left most bound
        if x < 0 {
            if self.arrowOffset == 0 {
                self.arrowOffset = x - padding
            }
            x = 0
        }
        
        // If the content pushes us off the vertical bounds we might have to be more drastic and flip the arrow direction
        if ((self.bubblePosition == KDBubbleArrowPosition.kTop) && (y + height > yBounds)) {
            self.bubblePosition = KDBubbleArrowPosition.KBottom
            
            // Restart the entire process
            let flippedFrame = self.calculateFrameWithFont(self.bubbleTextFont)
            y = flippedFrame.origin.y
            height = flippedFrame.size.height
            
        } else if ((self.bubblePosition == KDBubbleArrowPosition.KBottom) && (y < 0)) {
            
            self.bubblePosition = KDBubbleArrowPosition.kTop
            
            // Restart the entire process
            let flippedFrame = self.calculateFrameWithFont(self.bubbleTextFont)
            y = flippedFrame.origin.y
            height = flippedFrame.size.height
        }
        
        self.frame = CGRectMake(x, y, width, height)
    }
    
    /*!
     *  @author     :   Kedar Desai
     *  @desc       :   This methods calculates the bubble rame according to its font.
     *  @param      :   font
     *  @return     :   self.frame
     */
    func calculateFrameWithFont(font: UIFont?) -> CGRect {
        
        //Calculation of the bubble position
        var x: CGFloat = self.attachedFrame!.origin.x
        var y: CGFloat = self.attachedFrame!.origin.y
        
        let size: CGSize = self.sizeWithFont(font!)
        
        var widthDelta: CGFloat = 0.0
        var heightDelta: CGFloat = 0.0
        
        switch self.bubblePosition! {
        case .kLeft:
            y += (self.attachedFrame!.size.height/2) - (size.height/2)
            x += (self.bubblePosition!==KDBubbleArrowPosition.kLeft) ? (self.arrowSpace + self.attachedFrame!.size.width) : -((self.arrowSpace*2) + size.width)
            widthDelta = self.arrowSize;
            
        case .kRight:
            y += (self.attachedFrame!.size.height/2) - (size.height/2)
            x += (self.bubblePosition! == KDBubbleArrowPosition.kLeft) ? (self.arrowSpace + self.attachedFrame!.size.width) : -((self.arrowSpace*2) + size.width)
            widthDelta = self.arrowSize
            
        default: //  for Top and Bottom
            x += (self.attachedFrame!.size.width/2) - (size.width/2)
            y += (self.bubblePosition! == KDBubbleArrowPosition.kTop) ? (self.arrowSpace + self.attachedFrame!.size.height) : -((self.arrowSpace*2) + size.height);
            heightDelta = self.arrowSize
        }
        
        return CGRectMake(x, y, size.width + widthDelta, size.height + heightDelta)
    }
    
    /*!
     *  @author     :   Kedar Desai
     *  @desc       :   This calculatesthe size of bubble. Gets exact size of bubble title determined by the strings attributes.
     *  @param      :   font
     *  @return     :   CGSize
     */
    func sizeWithFont(font: UIFont) -> CGSize {
        
        let window: CGRect = UIApplication.sharedApplication().keyWindow!.frame
        
        var widthDelta: CGFloat = 0
        switch self.bubblePosition! {
        case .kLeft:
            // Make space for an arrow on left side
            widthDelta = arrowSize;
            
        case .kRight:
            // Make space for an arrow on left side
            widthDelta = arrowSize;
            
        default:
            widthDelta = 0.0
        }
        
        let attributes = [NSFontAttributeName:font]
        let resultRect: CGRect = self.bubbleTitle!.boundingRectWithSize(CGSizeMake(window.size.width - widthDelta - (self.bubblePadding * 3), CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        let result: CGSize = resultRect.size
        
        return CGSizeMake(result.width + (self.bubblePadding*3), result.height + (self.bubblePadding*2.5))
    }
    
    func offsets() -> CGSize {
        
        let width: CGFloat = (self.bubblePosition==KDBubbleArrowPosition.kLeft) ? self.arrowSize : 0
        let height: CGFloat = (self.bubblePosition==KDBubbleArrowPosition.kTop) ? self.arrowSize : 0
        
        return CGSizeMake(width, height)
    }
    
    
    // MARK: - Animation Methods -
    
    func animate() {
        let options: UIViewAnimationOptions = [.Repeat, .CurveEaseInOut]
        UIView.animateWithDuration(2.0, delay: 0.3, options: options, animations: {
                self.transform = CGAffineTransformMakeTranslation(0, -5)
            }, completion: nil)
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
