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
        self.keyModel = key

        setup()
    }
    
    required init(frame frameRect: NSRect, key: Keys) {
        super.init(frame: frameRect)
        self.keyModel = key
        setup()
    }
    
    private func setup() {
        roundCorners(cornerRadius: 5.0)
        let text = NSString(utf8String: keyModel.keyLetter)
        if (text == "BACKSPACE") {
            textSize = 10.0
        } else {
            textSize = 12.0
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        // Leave empty to detect drag and click
    }
    
    override func mouseDragged(with event: NSEvent) {
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setDataProvider(self, forTypes: [.color])
        let draggingImage = NSImage(size: NSSize(width: 18, height: 18))
        draggingImage.lockFocus()
        keyModel.color.nsColor.drawSwatch(in: NSRect(x: 0, y: 0, width: 18, height: 18))
        draggingImage.unlockFocus()
        let dragPoint = convert(event.locationInWindow, from: nil)
        let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
        draggingItem.setDraggingFrame(NSRect(x: dragPoint.x-11, y: dragPoint.y-6, width: 18, height: 18),
                                      contents: draggingImage)
        beginDraggingSession(with: [draggingItem], event: event, source: self)
        
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
        // super.draw(rect)
        
        // fill center
        let well = NSRect(x: 0, y: 0, width: frame.width, height: frame.height)
        keyModel.color.nsColor.set()
        well.fill()
        
        // create border if selected
        bezel = NSBezierPath(rect:bounds)
        bezel.lineWidth = 5.0
        if isSelected {
            if (keyModel.color.nsColor.scaledBrightness < 0.5) {
                let bright = map(x: Float(keyModel.color.nsColor.scaledBrightness), in_min: 0, in_max: 0.5, out_min: 0, out_max: 0.8)
                NSColor.white.usingColorSpace(.genericRGB)?.darkerColor(percent: bright).set()

            } else {
                keyModel.color.nsColor.darkerColor(percent: 0.5).set()
                bezel.lineWidth = 6.0
            }
        } else {
            keyModel.color.nsColor.set()
        }
        bezel.stroke()
        
        // Add letter text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: (keyModel.color.nsColor.scaledBrightness > 0.5) ? NSColor.black : NSColor.white,
            .font: NSFont.systemFont(ofSize: textSize)
        ]
        let heightT: CGFloat = (textSize == 10.0) ? 12 : 15
        let newRect = NSRect(x: 0, y: (bounds.size.height - heightT) / 2, width: bounds.size.width, height: heightT)
        
        let text = NSString(utf8String: keyModel.keyLetter)
        text!.draw(in: newRect, withAttributes: attributes)
    }
    
    private func map(x: Float, in_min: Float, in_max: Float, out_min: Float, out_max: Float) -> Double {
        let t = x - in_min
        let v = out_max - out_min
        let n = (in_max - in_min) + out_min
        return Double((t * v) / n)
    }

    func setColor(newColor: NSColor) {
        keyModel.color = newColor.getRGB
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
                ColorController.shared.setColor(keyModel.color.nsColor)
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

extension KeysView: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession,
                         sourceOperationMaskFor context: NSDraggingContext)
        -> NSDragOperation {
            return .generic
    }
    
}

extension KeysView: NSPasteboardItemDataProvider {
    func pasteboard(_ pasteboard: NSPasteboard?,
                    item: NSPasteboardItem,
                    provideDataForType type: NSPasteboard.PasteboardType) {
        guard let pasteboard = pasteboard else {
            return
        }
        keyModel.color.nsColor.write(to: pasteboard)
    }
}
