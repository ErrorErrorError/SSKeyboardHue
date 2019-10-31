//
//  MultiGradientSlider.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/27/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa
protocol MultiGradientSliderDelegate: class {
    func sliderDidChange(_ sliderThumb: SliderThumb, mouseUp: Bool)
}

@IBDesignable
class MultiGradientSlider: NSView {
    weak var delegate: MultiGradientSliderDelegate?

    var backgroundColorGradient: NSGradient!
    let widthSlider: CGFloat = 18
    let heightSlider: CGFloat = 21
    var gradientMode: PerKeyModes = ColorShift
    
    var currentSlider: SliderThumb!
    var maxSize = 14
        
    override var wantsDefaultClipping: Bool {
        return false
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        wantsLayer = true
        layer?.masksToBounds = false
    }
    
    private func setup() {
        let thumbOne = SliderThumb(frame: NSRect(x: 0, y: 0, width: widthSlider, height: heightSlider))
        let thumbTwo = SliderThumb(frame: NSRect(x: 60, y: 0, width: widthSlider, height: heightSlider))
        let thumbThree = SliderThumb(frame: NSRect(x: 120, y: 0, width: widthSlider, height: heightSlider))
        thumbOne.color = RGB(r: 0xff, g: 0x0, b: 0xe1).nsColor
        thumbTwo.color = RGB(r: 0xff, g: 0xea, b: 0).nsColor
        thumbThree.color = RGB(r: 0, g: 0xcc, b: 0xff).nsColor
        addSubview(thumbOne)
        addSubview(thumbTwo)
        addSubview(thumbThree)
        
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        let currentPoint = convert(event.locationInWindow, from: nil)
        
        for i in subviews {
            if (NSPointInRect(currentPoint, i.frame)) {
                currentSlider = i as? SliderThumb
            }
        }
        
        if (currentSlider != nil) {
            return
        }
        
        let point = calcPoint(point: currentPoint)
        let newRectForThumb = NSRect(x: point.x, y: point.y, width: widthSlider, height: heightSlider)
        let newThumb = SliderThumb(frame: newRectForThumb)
        addSubview(newThumb)
        newThumb.color = backgroundColorGradient.interpolatedColor(atLocation: point.x / (bounds.width - widthSlider))
        
    }
    
    override func mouseDragged(with event: NSEvent) {
        if (currentSlider == nil) {
            return super.mouseDragged(with: event)
        }
        
        let currentPoint = convert(event.locationInWindow, from: nil)
        currentSlider.setFrameOrigin(calcPoint(point: currentPoint))
        needsDisplay = true
        
        delegate?.sliderDidChange(currentSlider, mouseUp: false)
    }
    
    private func calcPoint(point: NSPoint) -> NSPoint {
        var x: CGFloat
        var y: CGFloat
        
        if (point.x - widthSlider/2 < 0) {
            x = 0
        } else if (point.x - widthSlider/2 > bounds.width - widthSlider) {
            x = bounds.width - widthSlider
        } else {
            x = point.x - widthSlider/2
        }
        
        if (point.y > 0) {
            y = 0
        } else {
            y = point.y
        }
        
        return NSPoint(x: x, y: y)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        if (currentSlider != nil) {
            if (subviews.count > 1) {
                if (currentSlider.frame.origin.y < 0) {
                    currentSlider.removeFromSuperview()
                }
            } else {
                if (currentSlider.frame.origin.y < 0) {
                    currentSlider.setFrameOrigin(NSPoint(x: currentSlider.frame.origin.x, y: 0))
                }
            }
            
            delegate?.sliderDidChange(currentSlider, mouseUp: true)
            currentSlider = nil
        }
        
        needsDisplay = true
    }
    
    func getSubviewsInOrder() -> [SliderThumb] {
        var subviewsInOrder: [SliderThumb] = subviews as! [SliderThumb]
        for i in 0..<subviews.count {
            for k in (i+1)..<subviews.count {
                if (subviews[i].frame.origin.x > subviews[k].frame.origin.x) {
                    let temp = subviews[i]
                    subviewsInOrder[i] = subviews[k] as! SliderThumb;
                    subviewsInOrder[k] = temp as! SliderThumb;
                }
             }
        }
        return subviewsInOrder
    }
    
    func setThumbsFromTransitions(transitions: UnsafeMutablePointer<KeyTransition>, count: Int) {
        for view in subviews {
            view.removeFromSuperview()
        }

        var total: CGFloat = 0
        for i in 0..<count {
            total += CGFloat(transitions[i].duration)
        }
        
        var xPoint:CGFloat = 0
        for i in 0..<count {
            let transition = transitions[i]
            let point = NSPoint(x: xPoint, y: 0)
            xPoint += (CGFloat(transition.duration) * (bounds.width - widthSlider)) / total
            let size = NSSize(width: widthSlider, height: heightSlider)
            let rect = NSRect(origin: point, size: size)
            let newThumb = SliderThumb(frame: rect, trans: transition)
            addSubview(newThumb)
        }
        needsDisplay = true
    }
    
    func getTransitionArray() -> [KeyTransition] {
        var transitions: [KeyTransition] = []
        
        let sliderThumbs = getSubviewsInOrder()
        for i in sliderThumbs {
            transitions.append(i.transition)
        }
        
        return transitions
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let newRect = NSRect(x: bounds.origin.x + widthSlider/2, y: heightSlider, width: bounds.width - widthSlider, height: bounds.height - heightSlider)
        var colorArr: [NSColor] = []
        var location: [CGFloat] = []
        
        let sliderArray = getSubviewsInOrder()
        
        if (gradientMode == ColorShift) {
            for slider in sliderArray {
                colorArr.append(slider.color)
                let point = slider.frame.origin.x / (bounds.width - widthSlider)
                location.append(point)
            }
            
            // Sets the first and last color with the same color
            colorArr.append(sliderArray[0].color)
            location.append(1.0)
        } else if (gradientMode == Breathing){
            for i in 0..<sliderArray.count {
                var halfDistance: CGFloat
                if ((i + 1) < sliderArray.count) {
                    halfDistance = ((sliderArray[i + 1].frame.origin.x + sliderArray[i].frame.origin.x) / 2) / newRect.width
                } else {
                    halfDistance = ((newRect.width + sliderArray[i].frame.origin.x) / 2) / newRect.width
                }
                
                colorArr.append(sliderArray[i].color)
                colorArr.append(NSColor.black)
                let point = sliderArray[i].frame.origin.x / newRect.width
                location.append(point)
                location.append(halfDistance)
            }
            // Sets the first and last color with the same color
            colorArr.append(sliderArray[0].color)
            location.append(1.0)
        }

        backgroundColorGradient = NSGradient(colors: colorArr, atLocations: location, colorSpace: .genericRGB)
        backgroundColorGradient.draw(in: newRect, angle: 0)
    }
    
}
