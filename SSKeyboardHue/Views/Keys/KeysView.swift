//
//  SSKeyboardKeys.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/3/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

@IBDesignable
class KeysView: NSView {
    var isSelected = false
    var bezel: NSBezierPath!
    var keyModel: KeysWrapper!
    var textSize: CGFloat!
    private var currentColor: NSColor!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
        
    }
    
    required init?(coder: NSCoder,key: KeysWrapper) {
        super.init(coder: coder)
        self.keyModel = key

        setup()
    }
    
    required init(frame frameRect: NSRect, key: KeysWrapper) {
        super.init(frame: frameRect)
        self.keyModel = key
        setup() 
    }
    
    private func setup() {
        roundCorners(cornerRadius: 5.0)
        let text = NSString(utf8String: keyModel.getKeyLetter())

        if (text == "BACKSPACE") {
            textSize = 10.0
        } else {
            textSize = 12.0
        }
        
        if (keyModel.getMode() == Steady) {
            currentColor = keyModel.getMainColor().nsColor.usingColorSpace(.genericRGB)
        } else if (keyModel.getMode() == Reactive) {
            currentColor = keyModel.getMainColor().nsColor.usingColorSpace(.genericRGB)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        if (isSelected) {
            isSelected = false
        } else {
            isSelected = true
        }
        
        setSelected(selected: isSelected, fromGroupSelection: false)
    }
    
    override func draw(_ rect: NSRect) {
        // fill center
        let well = NSRect(x: 0, y: 0, width: frame.width, height: frame.height)
        currentColor.set()
        well.fill()
        
        // create border if selected
        bezel = NSBezierPath(rect:bounds)
        bezel.lineWidth = 5.0
        if isSelected {
            if (currentColor.scaledBrightness < 0.5) {
                let bright = KeysView.map(x: currentColor.scaledBrightness, in_min: 0, in_max: 0.5, out_min: 0, out_max: 0.8)
                NSColor.white.usingColorSpace(.genericRGB)?.darkerColor(percent: Double(bright)).set()

            } else {
                currentColor.darkerColor(percent: 0.5).set()
                bezel.lineWidth = 6.0
            }
        } else {
            currentColor.set()
        }
        bezel.stroke()
        
        // Add letter text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: (currentColor.scaledBrightness > 0.5) ? NSColor.black : NSColor.white,
            .font: NSFont.systemFont(ofSize: textSize)
        ]
        let heightT: CGFloat = (textSize == 10.0) ? 12 : 15
        let newRect = NSRect(x: 0, y: (bounds.size.height - heightT) / 2, width: bounds.size.width, height: heightT)
        
        let text = NSString(utf8String: keyModel.getKeyLetter())
        text!.draw(in: newRect, withAttributes: attributes)
    }
    
    public static func map(x: CGFloat, in_min: CGFloat, in_max: CGFloat, out_min: CGFloat, out_max: CGFloat) -> CGFloat {
        let t = x - in_min
        let v = out_max - out_min
        let n = (in_max - in_min) + out_min
        return CGFloat((t * v) / n)
    }

    
    func setSteady(newColor: NSColor) {
        keyModel.setSteadyMode(newColor.getRGB)
        currentColor = newColor
        needsDisplay = true
    }
    
    func setReactive(active: NSColor, rest: NSColor, speed: UInt16) {
        keyModel.setReactiveMode(active.getRGB, rest.getRGB, speed)
        currentColor = rest
        needsDisplay = true
    }
    
    func setEffectKey(_id: uint8, mode: PerKeyModes, color: NSColor) {
        keyModel.setEffectKey(_id, mode)
        currentColor = color
        needsDisplay = true
    }
    
    func setDisabled() {
        keyModel.setDisabled()
        currentColor = RGB(r: 0, g: 0, b: 0).nsColor
        needsDisplay = true
    }
        
    func getColor() -> NSColor {
        return keyModel.getMainColor().nsColor
    }
    
    func setSelected(selected: Bool, fromGroupSelection: Bool) {
        isSelected = selected
        if (selected && fromGroupSelection) {
            if (!KeyboardManager.shared.keysSelected.contains(self)) {
                KeyboardManager.shared.keysSelected.add(self)
            }
        } else if (selected && !fromGroupSelection) {
            if (KeyboardManager.shared.keysSelected.count < 1) {
                ColorController.shared.setKey(key: keyModel)
            }
            
            if (!KeyboardManager.shared.keysSelected.contains(self)) {
                KeyboardManager.shared.keysSelected.add(self)
            }
            
        } else {
            KeyboardManager.shared.keysSelected.remove(self)
        }
        
        needsDisplay = true
    }
}
