//
//  KeyboardView.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/5/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class KeyboardView: NSView {
    var isMouseBeingDragged = false
    var startPoint: NSPoint!
    var shapeLayer: CAShapeLayer!
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        //setup()
    }
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        //setup()
    }
    
    func setup() {
        //shapeLayer = CAShapeLayer()
    }

    override func mouseDown(with event: NSEvent) {
        resetKeysSelected()
        startPoint = convert(event.locationInWindow, from: nil)        
        shapeLayer = CAShapeLayer(layer: layer!)
        shapeLayer.lineWidth = 1.0;
        shapeLayer.strokeColor = NSColor.blue.cgColor;
        shapeLayer.fillColor = NSColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.2).cgColor;
        layer?.addSublayer(shapeLayer)
    }
    
    override func mouseDragged(with event: NSEvent) {
        isMouseBeingDragged = true
        let point: NSPoint = convert(event.locationInWindow, from: nil)
        let path: CGMutablePath = CGMutablePath()
        path.move(to: startPoint)
        path.addLine(to: NSPoint(x: startPoint.x, y: point.y))
        path.addLine(to: point)
        path.addLine(to: NSPoint(x: point.x, y: startPoint.y))
        path.closeSubpath()
        shapeLayer.path = path
        for key in subviews {
            let keyCenter = NSPoint(x: key.frame.origin.x + key.frame.size.width/2,
                                     y: key.frame.origin.y + key.frame.size.height/2)
            if (path.contains(keyCenter)) {
                if ((key as! KeyboardKeys).isSelected != true) {
                    (key as! KeyboardKeys).setSelected(selected: true)
                }
            } else {
                (key as! KeyboardKeys).setSelected(selected: false)
            }
        }
    }
    
    func resetKeysSelected() {
        for i in subviews {
            (i as! KeyboardKeys).setSelected(selected: false)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if (shapeLayer != nil) {
            shapeLayer.removeFromSuperlayer()
            shapeLayer = nil
        }
    }
    
    var changedAlphanumKeys: NSArray
    var changedModifiersKeys: NSArray
    var changedEnterKeys: NSArray
    var changedSymbolKeys: NSArray
    
    func changedAlphanums() {
        print("Alphanums")
    }
    
    func changedModifiers() {
        print("Modifiers")
    }
    
    func changedEnter() {
        print("Enter")
    }
    
    func changedSymbol() {
        print("Symbol")
    }
}
