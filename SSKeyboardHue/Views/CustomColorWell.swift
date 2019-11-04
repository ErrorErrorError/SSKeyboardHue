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
        super.mouseDown(with: event)
        if (isSelected) {
            isSelected = false
        } else {
            isSelected = true
        }
        
        checkSelected()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        color.setFill()
        dirtyRect.fill()
        let border = NSBezierPath(rect: bounds)
        border.lineWidth = 5.0
        if isSelected {
            if (color.scaledBrightness < 0.5) {
                let bright = KeysView.map(x: color.scaledBrightness, in_min: 0, in_max: 0.5, out_min: 0, out_max: 0.8)
                NSColor.white.usingColorSpace(.genericRGB)?.darkerColor(percent: Double(bright)).set()

            } else {
                color.darkerColor(percent: 0.5).set()
                border.lineWidth = 6.0
            }
        } else {
            color.set()
        }
        border.stroke()
    }
    
    func checkSelected() {
        if (isSelected) {
            if (!ColorController.shared.reactionBoxColors.contains(self)) {
                if (ColorController.shared.reactionBoxColors.count > 0) {
                    (ColorController.shared.reactionBoxColors[0] as! CustomColorWell).removeSelected()
                }
                ColorController.shared.reactionBoxColors.add(self)
                ColorController.shared.setColor(color)
            }
        } else {
            ColorController.shared.reactionBoxColors.remove(self)
        }
        needsDisplay = true
    }

    
    func removeSelected() {
        isSelected = false
        ColorController.shared.reactionBoxColors.remove(self)
        needsDisplay = true
    }
}
