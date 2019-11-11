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
    var startPoint: NSPoint!
    var shapeLayer: CAShapeLayer!
    let serialQueue = DispatchQueue(label: "send_keyboard_command")
    var setMixedMode = false

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        KeyboardManager.shared.keyboardView = self
    }
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        KeyboardManager.shared.keyboardView = self
    }
    
    override func mouseEntered(with event: NSEvent) {
        let currentCursor = ColorController.shared.colorPicker.currentCursor!
        if (currentCursor.selectedSegment == 1) {
            NSCursor.init(image: currentCursor.image(forSegment: 1)!, hotSpot: NSPoint(x: 0.5, y: 0.5)).set()
        } else {
            NSCursor.init(image: currentCursor.image(forSegment: 0)!, hotSpot: NSPoint(x: 0.5, y: 0.5)).set()
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        let currentCursor = ColorController.shared.colorPicker.currentCursor!
        NSCursor.init(image: currentCursor.image(forSegment: 0)!, hotSpot: NSPoint(x: 0.5, y: 0.5)).set()
    }
    
    override func updateTrackingAreas() {
        for trackingArea in self.trackingAreas {
            self.removeTrackingArea(trackingArea)
        }

        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
        let trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }

    
    override func mouseDown(with event: NSEvent) {
        if (ColorController.shared.colorPicker.currentCursor.selectedSegment == 1) {
            resetKeysSelected()
            let currentPoint = convert(event.locationInWindow, from: nil)
            var keySelected: KeysView?
            for views in subviews.filter({ (filterView) -> Bool in
                guard let iskey = filterView as? KeysView else { return false }
                return (!iskey.isHidden)
            }) {
                if (NSPointInRect(currentPoint, views.frame)) {
                    keySelected = (views as! KeysView)
                    ColorController.shared.setKey(key: keySelected!.keyModel)
                    break
                }
            }
            
            if (keySelected == nil) {
                return
            }
            
            for i in subviews.filter({ (filterView) -> Bool in
                guard let iskey = filterView as? KeysView else { return false }
                return (!iskey.isHidden)
            }) {
                let key = i as! KeysView
                if (!key.isEqual(keySelected) && (keySelected!.keyModel.isEqual(key.keyModel))) {
                    key.setSelected(selected: true, fromGroupSelection: true)
                }
            }
            
            return
        }
        
        startPoint = convert(event.locationInWindow, from: nil)
        var resetKeys = true
        for i in subviews {
            if (NSPointInRect(startPoint, i.frame)) {
                resetKeys = false
                break
            }
        }
        
        if (resetKeys) {
            resetKeysSelected()
            // This passes the mouse down event to the key
            super.mouseDown(with: event)
        }
        
        shapeLayer = CAShapeLayer(layer: layer!)
        shapeLayer.lineWidth = 1.0;
        shapeLayer.strokeColor = NSColor.blue.cgColor;
        shapeLayer.fillColor = NSColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.2).cgColor;
        layer?.addSublayer(shapeLayer)
    }
    
    override func mouseDragged(with event: NSEvent) {
        if (ColorController.shared.colorPicker.currentCursor.selectedSegment == 1) {
            return
        }
        
        super.mouseDragged(with: event)
        let point: NSPoint = convert(event.locationInWindow, from: nil)
        let path: CGMutablePath = CGMutablePath()
        path.move(to: startPoint)
        path.addLine(to: NSPoint(x: startPoint.x, y: point.y))
        path.addLine(to: point)
        path.addLine(to: NSPoint(x: point.x, y: startPoint.y))
        path.closeSubpath()
        shapeLayer.path = path
        for keyView in subviews.filter({ (filterView) -> Bool in
            guard let iskey = filterView as? KeysView else { return false }
            return (!iskey.isHidden)
        }) {
            let keyView = keyView as! KeysView
            if (path.boundingBox.intersects(keyView.frame)) {
                if (!keyView.isSelected) {
                    keyView.setSelected(selected: true, fromGroupSelection: true)
                }
                
                var count = 0
                let keyArray = KeyboardManager.shared.keysSelected
                while (!setMixedMode && count < keyArray.count) {
                    let t = keyArray[count] as! KeysView
                
                    if (!(t.keyModel.isEqual(keyView.keyModel))) {
                        setMixedMode = true
                    } else {
                        count += 1
                    }
                }
                
                if (setMixedMode) {
                    ColorController.shared.colorPicker.setMixedMode(shouldSet: true)
                    setMixedMode = false
                } else {
                    let isEqual = ColorController.shared.colorPicker.isCurrentModeEqual(key: keyView.keyModel)
                    if (!isEqual) {
                        ColorController.shared.setKey(key: keyView.keyModel)
                    }
                }
                
            } else {
                if (keyView.isSelected) {
                    keyView.setSelected(selected: false, fromGroupSelection: true)
                }
            }
        }
    }
        
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        if (shapeLayer != nil) {
            shapeLayer.removeFromSuperlayer()
            shapeLayer = nil
        }
    }
    
    func resetKeysSelected() {
        for i in subviews {
            (i as! KeysView).setSelected(selected: false, fromGroupSelection: true)
        }
    }
    
    public func sendColorToKeyboard(region: UInt8, sendUpdateCommand: Bool) {

        var keyboardArray: [KeysWrapper] = []
        var regionKey: KeysWrapper
        
        regionKey = findAndGetKey(isRegionKey: true, keyToFind: region)!
        if (region == regions.0) {
            keyboardArray.append(regionKey)
            let modifierKeys = UnsafeRawBufferPointer(start: &modifiers, count: Int(kModifiersSize))
            for i in modifierKeys {
                keyboardArray.append(findAndGetKey(isRegionKey: false, keyToFind: i)!)
            }
            
        } else if (regions.1 == region) {
            keyboardArray.append(regionKey)
            let alphaKeys = UnsafeRawBufferPointer(start: &alphanums, count: Int(kAlphanumsSize))
            for i in alphaKeys {
                keyboardArray.append(findAndGetKey(isRegionKey: false, keyToFind: i)!)
            }
            
        } else if (regions.2 == region) {
            keyboardArray.append(regionKey)
            let enterKeys = UnsafeRawBufferPointer(start: &enter, count: Int(kEnterSize))
            for i in enterKeys {
                keyboardArray.append(findAndGetKey(isRegionKey: false, keyToFind: i)!)
            }
            
        } else {
            let specialKeys: UnsafeRawBufferPointer
            if (KeyboardManager.shared.keyboardManager.getKeyboardModel() == PerKeyGS65) {
                specialKeys = UnsafeRawBufferPointer(start: &special, count: Int(kSpecialSize))
            } else  {
                specialKeys = UnsafeRawBufferPointer(start: &specialPerKey, count: Int(kSpecialPerKeySize))
            }
            
            keyboardArray.append(regionKey)
            for i in specialKeys {
                keyboardArray.append(findAndGetKey(isRegionKey: false, keyToFind: i)!)
            }
        }
        
        serialQueue.async {
            let retVal = KeyboardManager.shared.keyboardManager.sendColorKeys(keyboardArray, sendUpdateCommand)
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
    public func updateKeys(forceRefresh: Bool = false, updateEffectKeys: Bool = false) {
        let modifiersKeys       = regions.0
        let alphaNumsKeys       = regions.1
        let enterKeys           = regions.2
        let specialOrNumpadKeys = regions.3
        
        var refreshModifiers: Bool
        var refreshAlphanums: Bool
        var refreshEnter: Bool
        var refreshSpecial: Bool
        
        if (updateEffectKeys) {
            updateEffects()
        }
        
        if (forceRefresh) {
            refreshModifiers = true
            refreshEnter     = true
            refreshSpecial   = true
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
    
    private func updateEffects() {
        let effectArray = KeyboardManager.shared.effectsArray
        for effect in effectArray {
            serialQueue.async {
                let retVal = KeyboardManager.shared.keyboardManager.sendEffect((effect as! KeyEffectWrapper), false)
                if (retVal != kIOReturnSuccess) {
                    print("could not send package", retVal)
                }
            }
        }
    }
    
    private func regionNeedsRefresh(regionToSearch: UInt8) -> Bool {
        var needRefresh = false
        var index = 0
        let keysSelected = KeyboardManager.shared.keysSelected
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
    
    
    public func getUsedEffectId() -> [UInt8] {
        var effectIds: [UInt8] = []
        for keySubview in subviews.filter({ (view) -> Bool in return !view.isHidden}) {
            let keys = keySubview as! KeysView
            let doesItContainId = effectIds.contains(keys.keyModel.getEffectId())
            if (!doesItContainId && (keys.keyModel.getMode() == ColorShift || keys.keyModel.getMode() == Breathing)) {
                effectIds.append(keys.keyModel.getEffectId())
            }
        }
        
        return effectIds
    }
    
    public func findAndGetKey(isRegionKey: Bool, keyToFind: UInt8) ->  KeysWrapper? {
        for keysSubView in subviews {
            let keyView = keysSubView as! KeysView
            let isKeyEqual = (keyView.keyModel.getKeyCode()) == keyToFind
            // if they equal the same, then it's the region key
            let isKeyRegionKey = keyView.keyModel.getKeyCode() == keyView.keyModel.getRegion()
            
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
