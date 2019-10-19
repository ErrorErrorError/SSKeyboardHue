//
//  CustomColorWell.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/17/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class CustomColorWell: NSColorWell {
    private var isBeingDragged = false
    var isSelected = false
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
            if (ColorController.shared.reactionModeSelected!.count < 1) {
                ColorController.shared.setColor(color)
            }
            
            ColorController.shared.reactionModeSelected?.add(self)
        } else if (!isSelected) {
            ColorController.shared.reactionModeSelected?.remove(self)
        }
        
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.drawWell(inside: dirtyRect)
        let border = NSBezierPath(rect: bounds)
        border.lineWidth = 5.0
        if (isSelected) {
            NSColor.white.setStroke()
            border.stroke()
        } else {
            color.setStroke()
            border.stroke()
        }
    }
    
    func removeSelected() {
        isSelected = false
        ColorController.shared.reactionModeSelected?.remove(self)
        needsDisplay = true
    }
}
