//
//  SwipeView.swift
//  DatesRUs
//
//  Created by Miguel Rivera on 10/28/15.
//  Copyright (c) 2015 Miguel Rivera. All rights reserved.
//

import UIKit
import Foundation

class SwipeView: UIView
{
    enum Direction
    {
        case None
        case Left
        case Right
    }
    
    weak var delegate: SwipeViewDelegate?
    
    let overlay: UIImageView = UIImageView()
    
    var direction: Direction?
    
    var innerView: UIView? {
        didSet {
            if let v = innerView {
                
                insertSubview(v, aboveSubview: overlay)
                v.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            }
        }
    }
    
    private var originalPoint: CGPoint?
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        initialize()
    }
    
    override init()
    {
        super.init()
        initialize()
    }
    
    private func initialize()
    {
        //change back to clear
        self.backgroundColor = UIColor.redColor()

        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "dragged:"))
        
        overlay.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        addSubview(overlay)
    }
    
    func dragged(gestureRecognizer: UIPanGestureRecognizer)
    {
        let distance = gestureRecognizer.translationInView(self)
        println("Distance x:\(distance.x) y: \(distance.y)")
        
        switch gestureRecognizer.state
        {
            case UIGestureRecognizerState.Began:
                originalPoint = center
            
            case UIGestureRecognizerState.Changed:
                
                let rotationPercentage = min(distance.x/(self.superview!.frame.width/2),1)
                let rotationAngle = (CGFloat(2 * M_PI/16) * rotationPercentage)
                transform = CGAffineTransformMakeRotation(rotationAngle)
                
                
                center = CGPointMake(originalPoint!.x + distance.x, originalPoint!.y + distance.y)
            
                updateOverlay(distance.x)
            
            case UIGestureRecognizerState.Ended:
                if abs(distance.x) < frame.width/4{
                    resetViewPositionAndTransformations()
                }
                else{
                    swipe(distance.x > 0 ? .Right : .Left)
                }
            
                
            
            default: println("Defalut GestureRecognizer Triggered")
                    break
        }
    }
    
    
    func swipe(s: Direction) {
        if s == .None{
            return
        }
        
        var parentWidth = superview!.frame.size.width
        
        if s == .Left {
            parentWidth *= -1
        }

        UIView.animateWithDuration(0.2, animations: {
            self.center.x = self.frame.origin.x + parentWidth
            }, completion: {
            //completion expects a boolean, that's what success is doing here, if true we run the next line
                success in
                if let d = self.delegate {
                    s == .Right ? d.swipedRight() : d.swipedLeft()
                }
            }
        )
//        UIView.animateWithDuration(0.2, animations: { () -> Void in
//                self.center.x = self.frame.origin.x + parentWidth
//        })
    }
    
    private func updateOverlay(distance: CGFloat) {
        var newDirection: Direction
        newDirection = distance < 0 ? .Left : .Right
        
        if newDirection != direction {
            direction = newDirection
            overlay.image = direction == .Right ? UIImage(named: "yeah-stamp") : UIImage(named: "nah-stamp")

        }
        overlay.alpha = abs(distance) / (superview!.frame.width/2)
    }
    
    private func resetViewPositionAndTransformations() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.center = self.originalPoint!
            self.transform = CGAffineTransformMakeRotation(0)
            
            self.overlay.alpha = 0
        })
    }
    
}

protocol SwipeViewDelegate: class {
    func swipedLeft()
    func swipedRight()
}