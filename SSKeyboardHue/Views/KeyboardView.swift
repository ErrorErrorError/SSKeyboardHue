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
            let keyView = key as! KeysView
            let keyCenter = NSPoint(x: key.frame.origin.x + key.frame.size.width/2,
                                     y: key.frame.origin.y + key.frame.size.height/2)
            if (path.contains(keyCenter)) {
                if (keyView.isSelected != true) {
                    keyView.setSelected(selected: true, fromGroupSelection: true)
                }
            } else {
                keyView.setSelected(selected: false, fromGroupSelection: true)
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
    
    public func sendColorToKeyboard(region: UInt8, sendUpdateCommand: Bool) {

        var keyboardArray: [UnsafeMutableRawPointer] = []
        var regionKey: UnsafeMutableRawPointer
        
        regionKey = findAndGetKey(isRegionKey: true, keyToFind: region)!.key()
        if (region == regions.0) {
            keyboardArray.reserveCapacity(Int(kModifiersSize + 1))
            keyboardArray.append(regionKey)
            let modifierKeys = UnsafeRawBufferPointer(start: &modifiers, count: Int(kModifiersSize))
            for i in modifierKeys {
                
                keyboardArray.append(findAndGetKey(isRegionKey: false, keyToFind: i)!.key())
            }
            
        } else if (regions.1 == region) {
            
            keyboardArray.reserveCapacity(Int(kAlphanumsSize + 1))
            keyboardArray.append(regionKey)
            let alphaKeys = UnsafeRawBufferPointer(start: &alphanums, count: Int(kAlphanumsSize))
            for i in alphaKeys {
                keyboardArray.append(findAndGetKey(isRegionKey: false, keyToFind: i)!.key())
            }
            
        } else if (regions.2 == region) {
            keyboardArray.reserveCapacity(Int(kEnterSize + 1))
            keyboardArray.append(regionKey)
            let enterKeys = UnsafeRawBufferPointer(start: &enter, count: Int(kEnterSize))
            for i in enterKeys {
                keyboardArray.append(findAndGetKey(isRegionKey: false, keyToFind: i)!.key())
            }
            
        } else {
            let specialKeys: UnsafeRawBufferPointer
            if (KeyboardManager.shared.keyboardManager.getKeyboardModel() == PerKeyGS65) {
                keyboardArray.reserveCapacity(Int(kSpecialSize + 1))
                specialKeys = UnsafeRawBufferPointer(start: &special, count: Int(kSpecialSize))
            } else  {
                keyboardArray.reserveCapacity(Int(kSpecialPerKeySize + 1))
                specialKeys = UnsafeRawBufferPointer(start: &specialPerKey, count: Int(kSpecialPerKeySize))
            }
            
            keyboardArray.append(regionKey)
            for i in specialKeys {
                keyboardArray.append(findAndGetKey(isRegionKey: false, keyToFind: i)!.key())
            }
        }
        
        serialQueue.async {
            let retVal = KeyboardManager.shared.keyboardManager.sendColorKeys(&keyboardArray, sendUpdateCommand)
            if (retVal != kIOReturnSuccess) {
                print("could not send package", retVal)
            }
        }
    }
    
    public func getKeysArray(region: UInt8) -> [KeysWrapper] {
        var keyboardArray: [KeysWrapper] = []
        var regionKey: KeysWrapper
        
        regionKey = findAndGetKey(isRegionKey: true, keyToFind: region)!
        if (region == regions.0) {
            keyboardArray.reserveCapacity(Int(kModifiersSize + 1))
            keyboardArray.append(regionKey)
            let modifierKeys = UnsafeRawBufferPointer(start: &modifiers, count: Int(kModifiersSize))
            for i in modifierKeys {
                
                keyboardArray.append(findAndGetKey(isRegionKey: false, keyToFind: i)!)
            }
            
        } else if (regions.1 == region) {
            
            keyboardArray.reserveCapacity(Int(kAlphanumsSize + 1))
            keyboardArray.append(regionKey)
            let alphaKeys = UnsafeRawBufferPointer(start: &alphanums, count: Int(kAlphanumsSize))
            for i in alphaKeys {
                keyboardArray.append(findAndGetKey(isRegionKey: false, keyToFind: i)!)
            }
            
        } else if (regions.2 == region) {
            keyboardArray.reserveCapacity(Int(kEnterSize + 1))
            keyboardArray.append(regionKey)
            let enterKeys = UnsafeRawBufferPointer(start: &enter, count: Int(kEnterSize))
            for i in enterKeys {
                keyboardArray.append(findAndGetKey(isRegionKey: false, keyToFind: i)!)
            }
            
        } else {
            let specialKeys: UnsafeRawBufferPointer
            if (KeyboardManager.shared.keyboardManager.getKeyboardModel() == PerKeyGS65) {
                keyboardArray.reserveCapacity(Int(kSpecialSize + 1))
                specialKeys = UnsafeRawBufferPointer(start: &special, count: Int(kSpecialSize))
            } else  {
                keyboardArray.reserveCapacity(Int(kSpecialPerKeySize + 1))
                specialKeys = UnsafeRawBufferPointer(start: &specialPerKey, count: Int(kSpecialPerKeySize))
            }
            
            keyboardArray.append(regionKey)
            for i in specialKeys {
                keyboardArray.append(findAndGetKey(isRegionKey: false, keyToFind: i)!)
            }
        }

        return keyboardArray
    }
    
    /**
     This method allows to refresh PerKey and GS65 keyboard if therewas any changes
    **/
    public func updateKeys(forceRefresh: Bool = false) {
        let modifiersKeys       = regions.0
        let alphaNumsKeys       = regions.1
        let enterKeys           = regions.2
        let specialOrNumpadKeys = regions.3
        
        var refreshModifiers: Bool
        var refreshAlphanums: Bool
        var refreshEnter: Bool
        var refreshSpecial: Bool
        
        if (forceRefresh) {
            refreshModifiers = true
            refreshEnter = true
            refreshSpecial = true
            refreshAlphanums = true
        } else {
            refreshModifiers = regionNeedsRefresh(regionToSearch: modifiersKeys)
            refreshAlphanums = regionNeedsRefresh(regionToSearch: alphaNumsKeys)
            refreshEnter     = regionNeedsRefresh(regionToSearch: enterKeys)
            refreshSpecial   = regionNeedsRefresh(regionToSearch: specialOrNumpadKeys)
        }
        //This allows to have consistent times between single and multiple keys
        let millis: UInt16 = 240
        KeyboardManager.shared.keyboardManager.setSleepInMillis(millis)
        
        if (refreshModifiers && !refreshAlphanums && !refreshEnter && !refreshSpecial) {
            sendColorToKeyboard(region: modifiersKeys, sendUpdateCommand: true)
        } else if (!refreshModifiers && refreshAlphanums && !refreshEnter && !refreshSpecial) {
            sendColorToKeyboard(region: alphaNumsKeys, sendUpdateCommand: true)
        } else if (!refreshModifiers && !refreshAlphanums && refreshEnter && !refreshSpecial) {
            sendColorToKeyboard(region: enterKeys, sendUpdateCommand: true)
        } else if (!refreshModifiers && !refreshAlphanums && !refreshEnter && refreshSpecial){
            sendColorToKeyboard(region: specialOrNumpadKeys, sendUpdateCommand: true)
        } else if (refreshModifiers && refreshAlphanums && !refreshEnter && !refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/2))
            sendColorToKeyboard(region: modifiersKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: alphaNumsKeys, sendUpdateCommand: true)
        } else if (refreshModifiers && !refreshAlphanums && refreshEnter && !refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/2))
            sendColorToKeyboard(region: modifiersKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: enterKeys, sendUpdateCommand: true)
        } else if (refreshModifiers && !refreshAlphanums && !refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/2))
            sendColorToKeyboard(region: modifiersKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, sendUpdateCommand: true)
        } else if (!refreshModifiers && refreshAlphanums && refreshEnter && !refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/2))
            sendColorToKeyboard(region: alphaNumsKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: enterKeys, sendUpdateCommand: true)
        } else if (!refreshModifiers && refreshAlphanums && !refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/2))
            sendColorToKeyboard(region: alphaNumsKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, sendUpdateCommand: true)
        } else if (!refreshModifiers && !refreshAlphanums && refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/2))
            sendColorToKeyboard(region: enterKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, sendUpdateCommand: true)
        } else if (refreshModifiers && refreshAlphanums && refreshEnter && !refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/3))
            sendColorToKeyboard(region: modifiersKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: alphaNumsKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: enterKeys, sendUpdateCommand: true)
        } else if (refreshModifiers && refreshAlphanums && !refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/3))
            sendColorToKeyboard(region: modifiersKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: alphaNumsKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, sendUpdateCommand: true)
        } else if (refreshModifiers && !refreshAlphanums && refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/3))
            sendColorToKeyboard(region: modifiersKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: enterKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, sendUpdateCommand: true)
        } else if (!refreshModifiers && refreshAlphanums && refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/3))
            sendColorToKeyboard(region: alphaNumsKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: enterKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, sendUpdateCommand: true)
        } else if (refreshModifiers && refreshAlphanums && refreshEnter && refreshSpecial) {
            KeyboardManager.shared.keyboardManager.setSleepInMillis(UInt16(millis/4))
            sendColorToKeyboard(region: modifiersKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: alphaNumsKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: enterKeys, sendUpdateCommand: false)
            sendColorToKeyboard(region: specialOrNumpadKeys, sendUpdateCommand: true)
        } else {
            // The last option is nothing was changed so we don't need to do anything at this point
            return
        }
    }
    
    private func regionNeedsRefresh(regionToSearch: UInt8) -> Bool {
        var needRefresh = false
        var index = 0
        let keysSelected = KeyboardManager.shared.keysSelected!
        while (!needRefresh && index < keysSelected.count) {
            let keys = keysSelected[index] as! KeysView
            if ((keys.keyModel.getRegion()) == regionToSearch) {
                needRefresh = true
            } else {
                index += 1
            }
        }
        return needRefresh
    }
    
    public func findAndGetKey(isRegionKey: Bool, keyToFind: UInt8) ->  KeysWrapper? {
        for keysSubView in subviews {
            let keyView = keysSubView as! KeysView
            let isKeyEqual = (keyView.keyModel.getKeyCode()) == keyToFind
            let keyText = NSString(utf8String: (keyView.keyModel.getKeyLetter()))
            let isKeyRegionKey = keyText == "A" || keyText == "ESC" || keyText == "ENTER" || keyText == "F7"
            
            if (isRegionKey && isKeyEqual && isKeyRegionKey) {
                return keyView.keyModel
            }
            else if (!isRegionKey && isKeyEqual && !isKeyRegionKey) {
                return keyView.keyModel
            }
        }
        
        // Will never get to this point
        return nil
    }
}
