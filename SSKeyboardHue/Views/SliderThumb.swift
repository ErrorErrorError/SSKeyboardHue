//
//  SliderThumb.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/29/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class SliderThumb: NSView {
    private var isSelected = false
    private var isBeingDragged = false
    var transition = KeyTransition()
    var color: NSColor = NSColor.white.usingColorSpace(.genericRGB)! {
        didSet {
            transition.color = color.getRGB
            calcDuration()
            needsDisplay = true
            superview?.needsDisplay = true
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    init(frame frameRect: NSRect, trans: KeyTransition) {
        super.init(frame: frameRect)
        transition = trans
        color = transition.color.nsColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func calcDuration() {
        var sliderArrays: [SliderThumb] = []
        if (superview != nil) {
            sliderArrays = (superview as! MultiGradientSlider).getSubviewsInOrder()
        } else {
            return
        }
            
        for i in 0..<sliderArrays.count {
            let thumb = sliderArrays[i]
            if (thumb.isEqual(to: self)) {
                let distance: CGFloat
                let widthSuperview: CGFloat = (superview!.bounds.width - bounds.width)
                if ((i + 1) < sliderArrays.count) {
                    let thumbFoward = sliderArrays[i + 1]
                    distance = (thumbFoward.frame.origin.x - thumb.frame.origin.x) / widthSuperview
                } else {
                    let firstThumb = sliderArrays[0]
                    distance = ((widthSuperview - thumb.frame.origin.x) + firstThumb.frame.origin.x) / widthSuperview
                }
                let currentSpeed = CGFloat(ColorController.shared.colorPicker.speedSlider.floatValue)
                let durationAnimation: UInt16 = UInt16(ceil(distance *  currentSpeed))
                transition.duration = durationAnimation
                break
            }
        }
    }
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if (isSelected) {
            isSelected = false
        } else {
            isSelected = true
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        isBeingDragged = true
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        if (isBeingDragged) {
            isSelected = false
            isBeingDragged = false
        }
        needsDisplay = true
        calcDuration()
        checkTransitionArray()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let bezierPath = NSBezierPath()
        bezierPath.move(to: NSPoint(x: bounds.width/2, y: bounds.height))
        bezierPath.line(to: NSPoint(x: bounds.width/2 - 2, y: bounds.height - 2))
        bezierPath.line(to: NSPoint(x: 0, y: bounds.height - 2))
        bezierPath.line(to: NSPoint(x: 0, y: 0))
        bezierPath.line(to: NSPoint(x: bounds.width, y: 0))
        bezierPath.line(to: NSPoint(x: bounds.width, y: bounds.height - 2))
        bezierPath.line(to: NSPoint(x: bounds.width / 2 + 2, y: bounds.height - 2))
        NSColor.gray.setFill()
        bezierPath.fill()
        
        let colorRect = NSRect(x: 2, y: 2, width: bounds.width - 4, height: bounds.width - 4)
        let border = NSBezierPath(rect: colorRect)

        
        if isSelected {
            if (color.scaledBrightness < 0.5) {
                let bright = KeysView.map(x: Float(color.scaledBrightness), in_min: 0, in_max: 0.5, out_min: 0, out_max: 0.8)
                NSColor.white.usingColorSpace(.genericRGB)?.darkerColor(percent: bright).set()

            } else {
                color.darkerColor(percent: 0.5).set()
                border.lineWidth = 7.0
            }
        } else {
            color.set()
        }
        border.stroke()
        
        color.setFill()
        colorRect.fill()
    }
    
    private func checkTransitionArray() {
        if (isSelected) {
            ColorController.shared.transitionThumbColors?.add(self)
        } else {
            ColorController.shared.transitionThumbColors?.remove(self)
        }
    }
    
    func removeSelected() {
        isSelected = false
        ColorController.shared.transitionThumbColors?.remove(self)
        needsDisplay = true
    }
}
