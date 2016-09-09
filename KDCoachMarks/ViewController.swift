//
//  ViewController.swift
//  KDCoachMarks
//
//  Created by Kedar Desai on 01/09/16.
//  Copyright © 2016 Kedar Desai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let coachMarks: NSMutableArray = NSMutableArray()
        
        let coachMark1 = KDCoachMarkMetadata()
        coachMark1.caption = "Synchronize your mail"
        coachMark1.rect = CGRectMake(6, 24, 40, 40)
        coachMark1.shape = KDCoachMarkShape.kCircle
        coachMark1.font = UIFont.boldSystemFontOfSize(14.0)
        coachMarks.addObject(coachMark1)
        
        let coachMark2 = KDCoachMarkMetadata()
        coachMark2.caption = "Create a new message"
        coachMark2.rect = CGRectMake(275, 24, 40, 40)
        coachMark2.shape = KDCoachMarkShape.kCircle
        coachMark2.font = UIFont.boldSystemFontOfSize(14.0)
        coachMarks.addObject(coachMark2)
        
        let coachMark3 = KDCoachMarkMetadata()
        coachMark3.caption = "Swipe for more options"
        coachMark3.rect = CGRectMake(125, 0, 60, 320)
        coachMark3.shape = KDCoachMarkShape.kSquare
        coachMark3.font = UIFont.boldSystemFontOfSize(14.0)
        coachMark3.isSwipeEnabled = true
        coachMark3.swipeDirection = KDCoachMarkSwipeDirection.kDownSwipe
        coachMarks.addObject(coachMark3)
        
        let coachMark4 = KDCoachMarkMetadata()
        coachMark4.caption = "Swipe for more options"
        coachMark4.rect = CGRectMake(0, 125, 320, 60)
        coachMark4.shape = KDCoachMarkShape.kSquare
        coachMark4.font = UIFont.boldSystemFontOfSize(14.0)
        coachMark4.isSwipeEnabled = true
        coachMark4.swipeDirection = KDCoachMarkSwipeDirection.kLeftSwipe
        coachMarks.addObject(coachMark4)
        
        let coachMarkView: KDCoachMarkView = KDCoachMarkView(frame: self.view.frame, coachMarks: coachMarks)
        
        self.view.addSubview(coachMarkView)
        coachMarkView.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

