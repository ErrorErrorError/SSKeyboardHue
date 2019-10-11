//
//  KeyboardView.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/5/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

@IBDesignable
class KeyboardView: NSView {
    var isMouseBeingDragged = false
    var startPoint: NSPoint!
    var shapeLayer: CAShapeLayer!
    let serialQueue = DispatchQueue(label: "queuename")

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        ColorController.shared.keyboardView = self
    }
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        ColorController.shared.keyboardView = self
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
                    (key as! KeyboardKeys).setSelected(selected: true, fromGroupSelection: true)
                }
            } else {
                (key as! KeyboardKeys).setSelected(selected: false, fromGroupSelection: true)
            }
        }
    }
    
    func resetKeysSelected() {
        for i in subviews {
            (i as! KeyboardKeys).setSelected(selected: false, fromGroupSelection: true)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if (shapeLayer != nil) {
            shapeLayer.removeFromSuperlayer()
            shapeLayer = nil
        }
    }
    
    public func colorToKeyboard(region: UInt8, createOutput: Bool) {

        var colorArray: [RGB] = []
        let regionColor: RGB
        if (region == regions.0) {
            colorArray.reserveCapacity(Int(kModifiersSize))
            let modifierKeys = UnsafeRawBufferPointer(start: &modifiers, count: Int(kModifiersSize))
            for i in modifierKeys {
                colorArray.append(findColorOfKey(isRegionKey: false, keyToFind: i))
            }
            
            regionColor = findColorOfKey(isRegionKey: true, keyToFind: region)
            
        } else if (regions.1 == region) {
            
            colorArray.reserveCapacity(Int(kAlphanumsSize))
            let alphaKeys = UnsafeRawBufferPointer(start: &alphanums, count: Int(kAlphanumsSize))
            for i in alphaKeys {
                colorArray.append(findColorOfKey(isRegionKey: false, keyToFind: i))
            }
            
            regionColor = findColorOfKey(isRegionKey: true, keyToFind: region)
            
        } else if (regions.2 == region) {
            colorArray.reserveCapacity(Int(kEnterSize))
            let enterKeys = UnsafeRawBufferPointer(start: &enter, count: Int(kEnterSize))
            for i in enterKeys {
                colorArray.append(findColorOfKey(isRegionKey: false, keyToFind: i))
            }
            
            regionColor = findColorOfKey(isRegionKey: true, keyToFind: region)
            
        } else {
            colorArray.reserveCapacity(Int(kSpecialSize))
            let specialKeys = UnsafeRawBufferPointer(start: &special, count: Int(kSpecialSize))
            for i in specialKeys {
                colorArray.append(findColorOfKey(isRegionKey: false, keyToFind: i))
            }
            
            regionColor = findColorOfKey(isRegionKey: true, keyToFind: region)
            
        }
        
        serialQueue.async {
            KeyboardManager.shared.keyboardManager.setSteadyMode(region, regionColor, &colorArray, createOutput)

        }

    }
    
    private func findColorOfKey(isRegionKey: Bool, keyToFind: UInt8) -> RGB {
        for keysSubView in subviews {
            let keyView = keysSubView as! KeyboardKeys
            let isKeyEqual = keyView.keyModel.key == keyToFind
            let isKeyRegionKey = keyView.keyModel.keyLetter == "A" || keyView.keyModel.keyLetter == "ESC" || keyView.keyModel.keyLetter == "ENTER" || keyView.keyModel.keyLetter == "F7"
            if (isRegionKey) {
                if (isKeyEqual && isKeyRegionKey) {
                    return keyView.getColor().getRGB
                }
            } else {
                if (isKeyEqual && !isKeyRegionKey) {
                    return keyView.getColor().getRGB
                }
            }
        }
        return RGB(r: 0, g: 0, b: 0)
    }
    
    
}
