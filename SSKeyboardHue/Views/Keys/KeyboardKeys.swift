//
//  SSKeyboardKeys.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/3/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class KeyboardKeys: NSColorWell {
    var isSelected = false
    var isBeingDragged = false
    var key: UInt8!
    var keyText: NSString!

    var colorKey: NSColor = NSColor.white {
        didSet {
            
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder,keyLetter: String, newColor: RGB) {
        super.init(coder: coder)
        self.colorKey = newColor.nsColor.usingColorSpace(NSColorSpace.genericRGB)!
        self.colorKey = newColor.nsColor.usingColorSpace(NSColorSpace.genericRGB)!
        self.keyText = keyLetter as NSString
        setup()
    }
    
    required init(frame frameRect: NSRect, keyLetter: String, newColor: RGB) {
        super.init(frame: frameRect)
        self.colorKey = newColor.nsColor.usingColorSpace(NSColorSpace.genericRGB)!
        self.color = newColor.nsColor.usingColorSpace(NSColorSpace.genericRGB)!
        self.keyText = keyLetter as NSString
        setup()
    }
    
    private func setup() {
        isBordered = false
        roundCorners(cornerRadius: 5.0)
        for keys in KeyboardLayoutGS65.keys {
            if (keys.value == String(keyText)){
                key = keys.key
                break
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        if (!isSelected && isBeingDragged) {
            setSelected(selected: false, fromGroupSelection: false)
            // ColorController.shared.currentKeys!.remove(self)
        } else if (!isSelected || !isSelected && !isBeingDragged) {
            setSelected(selected: true, fromGroupSelection: false)
            ColorController.shared.currentKeys!.add(self)
            // ColorController.shared.setColor(color.usingColorSpace(NSColorSpace.genericRGB)!)
            
        } else if (isSelected && isBeingDragged)  {
            setSelected(selected: true, fromGroupSelection: false)
            
        }  else {
            setSelected(selected: false, fromGroupSelection: false)
            ColorController.shared.currentKeys!.remove(self)
        }
        
        setNeedsDisplay()
    }
    
    override func mouseDragged(with event: NSEvent) {
        // super.mouseDown causes the icon drag to show and I only want it to show
        // when it's actually being dragged
        super.mouseDown(with: event)
        isBeingDragged = true
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        isBeingDragged = false
    }

    override func draw(_ rect: NSRect) {
        super.draw(rect)
        if isSelected {
            colorKey.darkerColor(percent: 0.5).set()
            let path = NSBezierPath(rect:bounds)
            path.lineWidth = 5.0
            path.stroke()
            
        } else {
            colorKey.set()
            let path = NSBezierPath(rect:bounds)
            path.lineWidth = 5.0
            path.stroke()
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: NSColor.white,
            .font: NSFont.systemFont(ofSize: 12.0)
        ]
        let newRect = NSRect(x: 0, y: (bounds.size.height - 15) / 2, width: bounds.size.width, height: 15)
        keyText.draw(in: newRect, withAttributes: attributes)
        
    }

    override func drawWell(inside insideRect: NSRect) {
        // colorKey.set()
        // insideRect.fill()
    }
    func setColor(newColor: NSColor) {
        colorKey = newColor
        color = newColor
        setNeedsDisplay()
    }
    
    func getColor() -> NSColor {
        return colorKey
    }

    func setSelected(selected: Bool, fromGroupSelection: Bool) {
        isSelected = selected
        if (selected && fromGroupSelection) {
            ColorController.shared.currentKeys!.add(self)
        } else if (selected && !fromGroupSelection) {
            ColorController.shared.currentKeys!.add(self)
            ColorController.shared.setColor(colorKey.usingColorSpace(NSColorSpace.genericRGB)!)
        } else {
            ColorController.shared.currentKeys!.remove(self)
            // ColorController.shared.setColor(color.usingColorSpace(NSColorSpace.genericRGB)!)
        }
        setNeedsDisplay()
    }

}
