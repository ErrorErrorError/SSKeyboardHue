//
//  GradientSliderCell.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/4/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

@IBDesignable
class GradientSliderCell: NSSliderCell {
    
    var colorA = NSColor.white
    var colorB = NSColor.black
    // private var barImage: CGImage?
    
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        let t = NSBezierPath(roundedRect: rect, xRadius: 2.0, yRadius: 2.0)
        NSGradient(starting: colorA, ending: colorB)?.draw(in: t, angle: 0)
    }
}
