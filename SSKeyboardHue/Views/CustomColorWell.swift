//
//  CustomColorWell.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/17/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class CustomColorWell: NSView {
    private var isBeingDragged = false
    var isSelected = false
    var color = NSColor.white.usingColorSpace(.genericRGB)! {
        didSet {
            needsDisplay = true
        }
    }
    override func mouseDown(with event: NSEvent) {
        if (isSelected) {
            isSelected = false
        } else {
            isSelected = true
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        if (isSelected) {
            if (ColorController.shared.reactionBoxColors!.count < 1) {
                ColorController.shared.setColor(color)
            }
            
            ColorController.shared.reactionBoxColors?.add(self)
        } else if (!isSelected) {
            ColorController.shared.reactionBoxColors?.remove(self)
        }
        
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        color.setFill()
        dirtyRect.fill()
        let border = NSBezierPath(rect: bounds)
        border.lineWidth = 5.0
        if isSelected {
            if (color.scaledBrightness < 0.5) {
                let bright = KeysView.map(x: Float(color.scaledBrightness), in_min: 0, in_max: 0.5, out_min: 0, out_max: 0.8)
                NSColor.white.usingColorSpace(.genericRGB)?.darkerColor(percent: bright).set()

            } else {
                color.darkerColor(percent: 0.5).set()
                border.lineWidth = 6.0
            }
        } else {
            color.set()
        }
        border.stroke()
    }
    
    func removeSelected() {
        isSelected = false
        ColorController.shared.reactionBoxColors?.remove(self)
        needsDisplay = true
    }
}
