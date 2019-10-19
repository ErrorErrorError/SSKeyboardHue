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
    var isBeingDragged = false
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
            currentColor = keyModel.getMainColor().nsColor
        } else if (keyModel.getMode() == Reactive) {
            currentColor = keyModel.getMainColor().nsColor
        }
    }
    
    override func mouseDown(with event: NSEvent) {
    }
    
    override func mouseDragged(with event: NSEvent) {
        /*
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setDataProvider(keyModel, forTypes: [.keysShift])
        let draggingImage = NSImage(size: NSSize(width: 18, height: 18))
        draggingImage.lockFocus()
        currentColor.drawSwatch(in: NSRect(x: 0, y: 0, width: 18, height: 18))
        draggingImage.unlockFocus()
        let dragPoint = convert(event.locationInWindow, from: nil)
        let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
        draggingItem.setDraggingFrame(NSRect(x: dragPoint.x-11, y: dragPoint.y-6, width: 18, height: 18),
                                      contents: draggingImage)
        beginDraggingSession(with: [draggingItem], event: event, source: self)
        */
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
        // fill center
        let well = NSRect(x: 0, y: 0, width: frame.width, height: frame.height)
        currentColor.set()
        well.fill()
        
        // create border if selected
        bezel = NSBezierPath(rect:bounds)
        bezel.lineWidth = 5.0
        if isSelected {
            if (currentColor.scaledBrightness < 0.5) {
                let bright = map(x: Float(currentColor.scaledBrightness), in_min: 0, in_max: 0.5, out_min: 0, out_max: 0.8)
                NSColor.white.usingColorSpace(.genericRGB)?.darkerColor(percent: bright).set()

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
    
    private func map(x: Float, in_min: Float, in_max: Float, out_min: Float, out_max: Float) -> Double {
        let t = x - in_min
        let v = out_max - out_min
        let n = (in_max - in_min) + out_min
        return Double((t * v) / n)
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
            if (!KeyboardManager.shared.keysSelected!.contains(self)) {
                KeyboardManager.shared.keysSelected!.add(self)
            }
        } else if (selected && !fromGroupSelection) {
            if (KeyboardManager.shared.keysSelected!.count < 1) {
                ColorController.shared.setKey(key: keyModel)
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
