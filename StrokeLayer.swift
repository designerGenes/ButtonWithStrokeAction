//
//  ShapeHandler.swift
//  StrokeThatShape
//
//  Created by Jaden Nation on 6/16/16.
//  Copyright © 2016 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit


public extension NSTimer {
  public class func schedule(delay delay: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
    let fireDate = delay + CFAbsoluteTimeGetCurrent()
    let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
    return timer
  }
}

public struct Tracer {
  var lineWidth: CGFloat
  var lineOffset: CGFloat
  var lineColor: UIColor
}


public class StrokeLayer: CAShapeLayer {
  var startSide: Int = 0
  var drawSpeed: Double = 4.0
  var color: CGColor = UIColor.redColor().CGColor
  var offset: CGFloat = 0
  
  
  // MARK: init methods
  required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
  
  public init(color: UIColor, speed: Double, lineWidth: CGFloat, offset: CGFloat, startSide: Int = 0) {
    self.startSide = startSide < 4 && startSide >= 0 ? startSide : 0
    self.color = color.CGColor
    self.drawSpeed = speed
    self.offset = offset
    
    super.init()
    self.lineWidth = lineWidth
  }
  
  // MARK: custom methods
  private func wait(time: NSTimeInterval, closure: (()->())? = nil) {
    NSTimer.schedule(delay: time) { timer in
      if let closure = closure { closure() }
    }
  }
  
  private func diamondPath(rect: CGRect) -> CGPathRef {
    let dPath = CGPathCreateMutable()
    let center = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect))
    let distFromCenter = CGRectGetWidth(rect) / 2   // assuming equilateral distance, CHANGE THIS
    let p0 = CGPoint(x: center.x, y: center.y - distFromCenter) ;
    let p1 = CGPoint(x: center.x + distFromCenter, y: center.y ) ;
    let p2 = CGPoint(x: center.x, y: center.y + distFromCenter) ;
    let p3 = CGPoint(x: center.x - distFromCenter, y: center.y)
    
    var points = [p0, p1, p2, p3]
    (0..<startSide).map { x in
      points.append(points.removeFirst())
    }
    
      CGPathMoveToPoint(dPath, nil, points[0].x, points[0].y)
      for p in points {
        CGPathAddLineToPoint(dPath, nil, p.x, p.y)
      }
      CGPathCloseSubpath(dPath)
      
      return dPath
  }
  
  public func startStrokeAnimation() {
    if let owner = self.superlayer {
      let dPath = diamondPath(owner.visibleRect.insetBy(dx: -self.offset, dy: -self.offset))
      self.path = dPath
      strokeColor = color
      fillColor = UIColor.clearColor().CGColor
      lineWidth = lineWidth
      lineJoin = kCALineJoinRound
      opacity = 1
      
      owner.addSublayer(self)
        let pathAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        let opacAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
      
      for (x, animation) in [pathAnimation, opacAnimation].enumerate() {
        animation.duration = drawSpeed
        animation.fromValue = x == 0 ? 0 : 0.5
        animation.toValue =  1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        addAnimation(animation, forKey: animation.keyPath)
      }

        
      
      }
  }
  
  public func killStrokeAnimation() {
    if let owner = self.superlayer {
      let killAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
      killAnimation.duration = 0.35
      killAnimation.fromValue = self.opacity
      killAnimation.toValue = 0
      addAnimation(killAnimation, forKey: killAnimation.keyPath)
      
      wait(0.25) {
        self.removeFromSuperlayer()
      }
    }
  }
  
} // MARK: end of class



  
  












