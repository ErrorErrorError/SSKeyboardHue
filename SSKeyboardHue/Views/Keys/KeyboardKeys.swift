//
//  SSKeyboardKeys.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/3/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

struct Keys {
    var key: UInt8
    var keyLetter: String
    var region: UInt8
    var color: RGB
};

@IBDesignable
class KeyboardKeys: NSColorWell {
    var isSelected = false
    var isBeingDragged = false
    // var key: UInt8!
    // var keyText: NSString!
    var bezel: NSBezierPath!
    // var colorKey: NSColor = NSColor.white
    var keyModel: Keys!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder,key: Keys
        ) {
        super.init(coder: coder)
        //self.colorKey = newColor.nsColor.usingColorSpace(NSColorSpace.genericRGB)!
        //self.colorKey = newColor.nsColor.usingColorSpace(NSColorSpace.genericRGB)!
        //self.keyText = keyLetter as NSString
        self.color = key.color.nsColor.usingColorSpace(NSColorSpace.genericRGB)!
        self.keyModel = key

        setup()
    }
    
    required init(frame frameRect: NSRect, key: Keys) {
        super.init(frame: frameRect)
        //self.colorKey = key.color.nsColor.usingColorSpace(NSColorSpace.deviceRGB)!
        self.color = key.color.nsColor.usingColorSpace(NSColorSpace.genericRGB)!
        self.keyModel = key
        // self.keyText = keyLetter as NSString
        // self.key = key
        
        setup()
    }
    
    private func setup() {
        isBordered = false
        roundCorners(cornerRadius: 5.0)
    }
    
    override func mouseDown(with event: NSEvent) {
        // Leave empty to detect drag and click
    }
    
    override func mouseDragged(with event: NSEvent) {
        // super.mouseDown causes the icon drag to show and I only want it to show
        // when it's actually being dragged
        // super.mouseDown(with: event)
        super.mouseDown(with: event)
        isBeingDragged = true
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        if (!isBeingDragged && !isSelected) {
            setSelected(selected: true, fromGroupSelection: false)
        } else if (!isBeingDragged && isSelected) {
            setSelected(selected: false, fromGroupSelection: false)
        } else {
            isBeingDragged = false
        }
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        bezel = NSBezierPath(rect:bounds)
        bezel.lineWidth = 5.0
        if isSelected {
            if (keyModel.color.nsColor.scaledBrightness < 0.5) {
                // colorKey.lighterColor(percent: 0.8).set()
                NSColor.white.set()
            } else {
                //NSColor.black.set()
                keyModel.color.nsColor.darkerColor(percent: 0.4).set()
                bezel.lineWidth = 6.0
            }
        } else {
            keyModel.color.nsColor.set()
        }
        bezel.stroke()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: (keyModel.color.nsColor.scaledBrightness > 0.5) ? NSColor.black : NSColor.white,
            .font: NSFont.systemFont(ofSize: 12.0)
        ]
        let newRect = NSRect(x: 0, y: (bounds.size.height - 15) / 2, width: bounds.size.width, height: 15)
        keyModel.keyLetter.draw(in: newRect, withAttributes: attributes)
        
    }
    
    override func drawWell(inside insideRect: NSRect) {
        super.drawWell(inside: insideRect)
    }
    func setColor(newColor: NSColor) {
        keyModel.color = newColor.getRGB
        color = newColor
        setNeedsDisplay(bounds)
    }
    
    func getColor() -> NSColor {
        return keyModel.color.nsColor
    }
    
    func setSelected(selected: Bool, fromGroupSelection: Bool) {
        isSelected = selected
        if (selected && fromGroupSelection) {
            if (!ColorController.shared.currentKeys!.contains(self)) {
                ColorController.shared.currentKeys!.add(self)
            }
        } else if (selected && !fromGroupSelection) {
            if (ColorController.shared.currentKeys!.count < 1) {
                ColorController.shared.setColor(keyModel.color.nsColor.usingColorSpace(NSColorSpace.genericRGB)!)
            }
            
            if (!ColorController.shared.currentKeys!.contains(self)) {
                ColorController.shared.currentKeys!.add(self)
            }
            
        } else {
            ColorController.shared.currentKeys!.remove(self)
        }
        
        setNeedsDisplay(bounds)
    }
}
