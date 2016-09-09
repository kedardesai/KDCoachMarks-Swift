//
//  KDCoachMarkMetadata.swift
//  KDCoachMarks
//
//  Created by Kedar Desai on 01/09/16.
//  Copyright © 2016 Kedar Desai. All rights reserved.
//

import UIKit

enum KDCoachMarkShape {
    // Coach Mark rect will be shown in circle.
    case kCircle
    // Coach Mark rect will be shown in sqaure.
    case kSquare
    case kOtherShape
}

enum KDCoachMarkSwipeDirection {
    // Left to Right swipe
    case kLeftSwipe
    // Right to left swipe
    case kRightSwipe
    // Up to Down swipe
    case kUpSwipe
    // Down to Up swipe
    case kDownSwipe
}

class KDCoachMarkMetadata: NSObject {
    
    /// This defines the frame of the components for which coach marks should be shown.
    var rect: CGRect?
    
    ///
    var poi: CGRect?
    
    /// This defines the caption for the components for which coach marks should be shown.
    var caption: String?
    
    /// This defines description of bubble.
    var desc: String?
    
    /// This defines the shape of coach mark for the components which should be shown.
    var shape: KDCoachMarkShape?
    
    /// This defines the font of text to be shown
    var font: UIFont?
    
    /// This defines the whether coack mark should move like a swipe or not, by defaults its false
    var isSwipeEnabled: Bool? = false
    
    /// This defines the moving coach mark's direction
    var swipeDirection: KDCoachMarkSwipeDirection?
    

}
