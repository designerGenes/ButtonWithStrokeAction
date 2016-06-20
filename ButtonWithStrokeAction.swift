//
//  ButtonWithStrokeAction.swift
//  StrokeThatShape
//
//  Created by Jaden Nation on 6/16/16.
//  Copyright © 2016 Jaden Nation. All rights reserved.
//

import UIKit
import Foundation

public class ButtonWithStrokeAction: UIControl {
  var focusImgView: UIImageView?
  var triggerTimer: NSTimer?
  
  var startSide: Int = 0
  var timerSpeed: Double = 4
  var tracers: [Tracer]  = [Tracer(lineWidth: 15, lineOffset: 10, lineColor: UIColor.blackColor())]
  
  
  var action: (()->())?
  
  // MARK: custom methods
  private func drawStrokeOverlay() {
    for tracer in tracers {
      let myDiamond = StrokeLayer(color: tracer.lineColor, speed: timerSpeed, lineWidth: tracer.lineWidth, offset: tracer.lineOffset, startSide: startSide)
      self.layer.addSublayer(myDiamond)
      myDiamond.startStrokeAnimation()
    }
    
    triggerTimer = NSTimer.schedule(delay: timerSpeed) { timer in
      if let action = self.action {
        self.removeStrokeOverlay()
        action()
      }
    }
    
    
  }
  
  private func removeStrokeOverlay() {
    if let target = self.layer.sublayers?.filter({$0 is StrokeLayer}) as? [StrokeLayer] {
      for tg in target {
        tg.killStrokeAnimation()
      }
      self.triggerTimer?.invalidate()
      self.triggerTimer = nil
    }
  }
  
  
  public func setProperties(timerSpeed timerSpeed: Double, startSide: Int, tracers: [Tracer]?, action: ()->() ) {
    self.startSide = startSide
    if let tracers = tracers { self.tracers = [tracers, self.tracers].flatMap({$0}) }
    self.timerSpeed = timerSpeed
    self.action = action
    
  }
  
  
  public init(img: UIImage) {
    let frame = CGRectMake(0, 0, 200, 200)
    focusImgView = UIImageView(image: img)
    focusImgView!.frame = frame
    focusImgView?.contentMode = .ScaleAspectFit
    
    super.init(frame: frame)
    self.addSubview(focusImgView!)
  }

  
  
  required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
  
  
  
  override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    drawStrokeOverlay()
    super.touchesBegan(touches, withEvent: event)
  }
  
  override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    if !touchInside { touchesEnded(touches, withEvent: event) }
    super.touchesMoved(touches, withEvent: event)
  }
  
  override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    removeStrokeOverlay()
    super.touchesEnded(touches, withEvent: event)
  }

}



