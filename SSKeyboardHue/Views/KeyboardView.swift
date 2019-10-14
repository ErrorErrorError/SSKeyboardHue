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
    let serialQueue = DispatchQueue(label: "send_keyboard_command")

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        KeyboardManager.shared.keyboardView = self
    }
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        KeyboardManager.shared.keyboardView = self
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
                if ((key as! KeysView).isSelected != true) {
                    (key as! KeysView).setSelected(selected: true, fromGroupSelection: true)
                }
            } else {
                (key as! KeysView).setSelected(selected: false, fromGroupSelection: true)
            }
        }
    }
    
    func resetKeysSelected() {
        for i in subviews {
            (i as! KeysView).setSelected(selected: false, fromGroupSelection: true)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if (shapeLayer != nil) {
            shapeLayer.removeFromSuperlayer()
            shapeLayer = nil
        }
    }
    
    public func sendColorToKeyboard(region: UInt8, createOutput: Bool) {

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
            let specialKeys: UnsafeRawBufferPointer
            if (KeyboardManager.shared.keyboardManager.getKeyboardModel() == PerKeyGS65) {
                colorArray.reserveCapacity(Int(kSpecialSize))
                specialKeys = UnsafeRawBufferPointer(start: &special, count: Int(kSpecialSize))
            } else  {
                colorArray.reserveCapacity(Int(kSpecialPerKeySize))
                specialKeys = UnsafeRawBufferPointer(start: &specialPerKey, count: Int(kSpecialPerKeySize))
            }
            
            for i in specialKeys {
                colorArray.append(findColorOfKey(isRegionKey: false, keyToFind: i))
            }

            regionColor = findColorOfKey(isRegionKey: true, keyToFind: region)
        }
        
        serialQueue.async {
            KeyboardManager.shared.keyboardManager.setSteadyMode(region, regionColor, &colorArray, createOutput)

        }
    }
    
    /**
     This method allows to refresh PerKey and GS65 keyboard if therewas any color change
    **/
    public func updateKeys() {
        let modifiersKeys = regions.0
        let alphaNumsKeys = regions.1
        let enterKeys =     regions.2
        let specialOrNumpadKeys = regions.3
    
        let refreshModifiers = regionNeedsRefresh(regionToSearch: modifiersKeys)
        let refreshAlphanums = regionNeedsRefresh(regionToSearch: alphaNumsKeys)
        let refreshEnter     = regionNeedsRefresh(regionToSearch: enterKeys)
        let refreshSpecial   = regionNeedsRefresh(regionToSearch: specialOrNumpadKeys)

        //This allows to have consistent times between single and multiple keys
        let millis: UInt16 = 120
        KeyboardManager.shared.keyboardManager.setSleepInMillis(millis)
        
        if (refreshModifiers && !refreshAlphanums && !refreshEnter && !refreshSpecial) {
            sendColorToKeyboard(region: modifiersKeys, createOutput: true)
        } else if (!refreshModifiers && refreshAlphanums && !refreshEnter && !refreshSpecial) {
            sendColorToKeyboard(region: alphaNumsKeys, createOutput: true)
        } else if (!refreshModifiers && !refreshAlphanums && refreshEnter && !refreshSpecial) {
            sendColorToKeyboard(region: enterKeys, createOutput: true)
        } else if (!refreshModifiers && !refreshAlphanums && !refreshEnter && refreshSpecial){
            sendColorToKeyboard(region: specialOrNumpadKeys, createOutput: true)
        } else if (refreshModifiers && refreshAlphanums && !refreshEnter && !refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/2))
            sendColorToKeyboard(region: modifiersKeys, createOutput: false)
            sendColorToKeyboard(region: alphaNumsKeys, createOutput: true)
        } else if (refreshModifiers && !refreshAlphanums && refreshEnter && !refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/2))
            sendColorToKeyboard(region: modifiersKeys, createOutput: false)
            sendColorToKeyboard(region: enterKeys, createOutput: true)
        } else if (refreshModifiers && !refreshAlphanums && !refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/2))
            sendColorToKeyboard(region: modifiersKeys, createOutput: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, createOutput: true)
        } else if (!refreshModifiers && refreshAlphanums && refreshEnter && !refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/2))
            sendColorToKeyboard(region: alphaNumsKeys, createOutput: false)
            sendColorToKeyboard(region: enterKeys, createOutput: true)
        } else if (!refreshModifiers && refreshAlphanums && !refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/2))
            sendColorToKeyboard(region: alphaNumsKeys, createOutput: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, createOutput: true)
        } else if (!refreshModifiers && !refreshAlphanums && refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/2))
            sendColorToKeyboard(region: enterKeys, createOutput: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, createOutput: true)
        } else if (refreshModifiers && refreshAlphanums && refreshEnter && !refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/3))
            sendColorToKeyboard(region: modifiersKeys, createOutput: false)
            sendColorToKeyboard(region: alphaNumsKeys, createOutput: false)
            sendColorToKeyboard(region: enterKeys, createOutput: true)
        } else if (refreshModifiers && refreshAlphanums && !refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/3))
            sendColorToKeyboard(region: modifiersKeys, createOutput: false)
            sendColorToKeyboard(region: alphaNumsKeys, createOutput: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, createOutput: true)
        } else if (refreshModifiers && !refreshAlphanums && refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/3))
            sendColorToKeyboard(region: modifiersKeys, createOutput: false)
            sendColorToKeyboard(region: enterKeys, createOutput: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, createOutput: true)
        } else if (!refreshModifiers && refreshAlphanums && refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/3))
            sendColorToKeyboard(region: alphaNumsKeys, createOutput: false)
            sendColorToKeyboard(region: enterKeys, createOutput: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, createOutput: true)
        } else if (refreshModifiers && refreshAlphanums && refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/4))
            sendColorToKeyboard(region: modifiersKeys, createOutput: false)
            sendColorToKeyboard(region: alphaNumsKeys, createOutput: false)
            sendColorToKeyboard(region: enterKeys, createOutput: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, createOutput: true)
        } else {
            print("This is not supposed to happen")
        }
        
    }
    
    private func regionNeedsRefresh(regionToSearch: UInt8) -> Bool {
        var needRefresh = false
        for i in KeyboardManager.shared.keysSelected! {
            let keys = i as! KeysView
            if (keys.keyModel.region == regionToSearch) {
                needRefresh = true
                break
            }
        }
        
        return needRefresh
    }
    
    private func findColorOfKey(isRegionKey: Bool, keyToFind: UInt8) -> RGB {
        for keysSubView in subviews {
            let keyView = keysSubView as! KeysView
            let isKeyEqual = keyView.keyModel.key == keyToFind
            let keyText = NSString(utf8String: keyView.keyModel.keyLetter)
            let isKeyRegionKey = keyText == "A" || keyText == "ESC" || keyText == "ENTER" || keyText == "F7"
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
