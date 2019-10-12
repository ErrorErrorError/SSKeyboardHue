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
    var bezel: NSBezierPath!
    var keyModel: Keys!
    var textSize: CGFloat!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder,key: Keys) {
        super.init(coder: coder)
        self.color = key.color.nsColor.usingColorSpace(NSColorSpace.genericRGB)!
        self.keyModel = key

        setup()
    }
    
    required init(frame frameRect: NSRect, key: Keys) {
        super.init(frame: frameRect)
        self.color = key.color.nsColor.usingColorSpace(NSColorSpace.genericRGB)!
        self.keyModel = key
        setup()
    }
    
    private func setup() {
        isBordered = false
        roundCorners(cornerRadius: 5.0)
        if (keyModel.keyLetter == "BACKSPACE") {
            textSize = 10.0
        } else {
            textSize = 12.0
        }
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
                let bright = map(x: Float(keyModel.color.nsColor.scaledBrightness), in_min: 0, in_max: 0.5, out_min: 0, out_max: 0.8)
                NSColor.white.usingColorSpace(.genericRGB)?.darkerColor(percent: bright).set()
                print(bright)

            } else {
                //NSColor.black.set()
                keyModel.color.nsColor.darkerColor(percent: 0.5).set()
                bezel.lineWidth = 6.0
            }
        } else {
            color.set()
        }
        bezel.stroke()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: (keyModel.color.nsColor.scaledBrightness > 0.5) ? NSColor.black : NSColor.white,
            .font: NSFont.systemFont(ofSize: textSize)
        ]
        let heightT: CGFloat = (textSize == 10.0) ? 12 : 15
        let newRect = NSRect(x: 0, y: (bounds.size.height - heightT) / 2, width: bounds.size.width, height: heightT)
        keyModel.keyLetter.draw(in: newRect, withAttributes: attributes)
        
    }
    
    func map(x: Float, in_min: Float, in_max: Float, out_min: Float, out_max: Float) -> Double {
        let t = x - in_min
        let v = out_max - out_min
        let n = (in_max - in_min) + out_min
        return Double((t * v) / n)
    }
    
    override func drawWell(inside insideRect: NSRect) {
        super.drawWell(inside: insideRect)
    }
    func setColor(newColor: NSColor) {
        keyModel.color = newColor.getRGB
        color = newColor
        needsDisplay = true
    }
    
    func getColor() -> NSColor {
        return keyModel.color.nsColor
    }
    
    func setSelected(selected: Bool, fromGroupSelection: Bool) {
        isSelected = selected
        if (selected && fromGroupSelection) {
            if (!KeyboardManager.shared.keysSelected!.contains(self)) {
                KeyboardManager.shared.keysSelected!.add(self)
            }
        } else if (selected && !fromGroupSelection) {
            if (KeyboardManager.shared.keysSelected!.count < 1) {
                ColorController.shared.setColor(keyModel.color.nsColor.usingColorSpace(NSColorSpace.genericRGB)!)
            }
            
            if (!KeyboardManager.shared.keysSelected!.contains(self)) {
                KeyboardManager.shared.keysSelected!.add(self)
            }
            
        } else {
            KeyboardManager.shared.keysSelected!.remove(self)
        }
        
        needsDisplay = true
    }
}
