//
//  ColorPickerController.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/3/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class ColorPickerController: NSViewController {
    var colorBackground = RGB(r: 30, g: 30, b: 30) // Dark Mode
    var textViewBackground = RGB(r: 52, g: 52, b: 52)
    @IBOutlet weak var colorWheelView: ColorWheelView!
    @IBOutlet weak var colorLabel: NSTextField!
    @IBOutlet weak var brightnessSlider: NSSlider!
    @IBOutlet weak var currentKeyMode: NSPopUpButtonCell!
    var hasSetExtended = false
    // Reactive View
    let activeColor = CustomColorWell(frame: NSRect(origin: CGPoint(x: 26, y: 50), size: CGSize(width: 25, height: 25)))
    let restColor = CustomColorWell(frame: NSRect(origin: CGPoint(x: 116, y: 50), size: CGSize(width: 25, height: 25)))
    let activeText = NSTextView(frame: NSRect(origin: CGPoint(x: 56, y: 45), size: CGSize(width: 45, height: 25)))
    let restText = NSTextView(frame: NSRect(origin: CGPoint(x: 146, y: 45), size: CGSize(width: 35, height: 25)))
    let speedSlider = NSSlider(frame: NSRect(x: 25, y: 5, width: 150, height: 20))
    let speedText = NSTextView(frame: NSRect(x:23, y: 30, width: 55, height: 10))
    let speedBox = NSTextView(frame: NSRect(x: 180, y: 13, width: 55, height: 10))
    
    var originalFrame: NSRect!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        colorWheelView.delegate = self
        ColorController.shared.colorPicker = self
        colorLabel.roundCorners(cornerRadius: 10.0)
        colorLabel.layer?.backgroundColor = textViewBackground.nsColor.cgColor
        colorLabel.isBezeled = false
        
        currentKeyMode.addItem(withTitle: "Steady")
        //currentKeyMode.addItem(withTitle: "ColorShift")
        //currentKeyMode.addItem(withTitle: "Breathing")
        currentKeyMode.addItem(withTitle: "Reactive")
        currentKeyMode.addItem(withTitle: "Disabled")
        setUpReactiveViews()
        
    }
    
    private func setUpReactiveViews() {
        
        activeColor.isBordered = false
        activeColor.color = RGB(r: 0xff, g: 0x00, b: 0x00).nsColor
        activeColor.roundCorners(cornerRadius: 5.0)
        activeColor.isHidden = true
        
        activeText.isHidden = true
        activeText.string = "Active"
        activeText.isEditable = false
        activeText.textColor = NSColor.white
        
        restColor.isBordered = false
        restColor.color = RGB(r: 0x00, g: 0x00, b: 0x00).nsColor
        restColor.roundCorners(cornerRadius: 5.0)
        restColor.isHidden = true
        
        restText.isHidden = true
        restText.string = "Rest"
        restText.isEditable = false
        restText.textColor = NSColor.white
        
        speedSlider.isHidden = true
        speedSlider.minValue = 100
        speedSlider.maxValue = 1000
        speedSlider.cell!.target = self
        speedSlider.cell!.action = #selector(setSpeed(_:))
        speedSlider.intValue = 300

        speedText.isHidden = true
        speedText.string = "Speed"
        speedText.isEditable = false
        speedText.textColor = NSColor.white
        
        speedBox.isHidden = true
        var trimmed = speedSlider.intValue.description
        trimmed.removeLast(2)
        speedBox.string = trimmed + "s"
        speedBox.isEditable = false
        speedBox.textColor = NSColor.white

        view.addSubview(activeText)
        view.addSubview(restText)
        view.addSubview(activeColor)
        view.addSubview(restColor)
        view.addSubview(speedSlider)
        view.addSubview(speedText)
        view.addSubview(speedBox)
    }
    private func showReactive(show: Bool) {
        let isHidden = (show) ? false : true
        activeColor.isHidden = isHidden
        restColor.isHidden = isHidden
        activeText.isHidden = isHidden
        restText.isHidden = isHidden
        speedSlider.isHidden = isHidden
        speedText.isHidden = isHidden
        speedBox.isHidden = isHidden
    }
    
    @IBAction func setKeyMode(_ sender: NSPopUpButtonCell) {
        if (KeyboardManager.shared.keyboardManager.getKeyboardModel() != ThreeRegion) {
            if (originalFrame == nil) {
                originalFrame = view.superview?.frame
            }
    
            if (sender.titleOfSelectedItem == "Reactive") {
                if (!hasSetExtended) {
                    view.superview?.frame = NSRect(origin: CGPoint(x: (view.superview?.frame.origin.x)!, y: (view.superview?.frame.origin.y)! - 70), size: CGSize(width: (view.superview?.frame.size.width)!, height: (view.superview?.frame.size.height)! + 70))
                    hasSetExtended = true
                }
                
                showReactive(show: true)
            } else {
                if (ColorController.shared.reactionModeSelected!.count > 0) {
                    for i in ColorController.shared.reactionModeSelected! {
                        (i as! CustomColorWell).removeSelected()
                    }
                }
                view.superview?.frame = ((originalFrame != nil) ? originalFrame : view.superview?.frame)!
                showReactive(show: false)
                hasSetExtended = false;
            }
            
            updateKeys(shouldUpdateKeys: true)
        }
        
    }

    @IBAction  func setSpeed(_ sender: NSSlider) {
        let event = NSApplication.shared.currentEvent
        if (event?.type == NSEvent.EventType.leftMouseUp) {
            if (currentKeyMode.titleOfSelectedItem == "Reactive") {
                    updateReactiveColors(shouldUpdateKeys: true)
            }
        }
        var trimmed = speedSlider.intValue.description
        trimmed.removeLast(2)
        speedBox.string = trimmed + "s"
    }
    
    override func viewWillAppear() {
        view.layer?.backgroundColor = colorBackground.nsColor.cgColor
        view.roundCorners(cornerRadius: 10.0)
        ColorController.shared.setColor(NSColor.white.usingColorSpace(.genericRGB)!)
    }
    
    /*
    private func speedAsString(speed: Int) {
        
    }
 */
    
    @IBAction func setBrightness(_ sender: NSSlider) {
        ColorController.shared.brightness = CGFloat((sender.maxValue-sender.doubleValue) / sender.maxValue)
        updateColorWheel(redrawCrosshair: false)
        updateLabel()
        
        let event = NSApplication.shared.currentEvent
        
        if event?.type == NSEvent.EventType.leftMouseUp {
            if (currentKeyMode.titleOfSelectedItem == "Steady") {
                updateKeys(shouldUpdateKeys: true)
            } else if (currentKeyMode.titleOfSelectedItem == "Reactive") {
                updateReactiveColors(shouldUpdateKeys: true)
            }
        } else {
            if (currentKeyMode.titleOfSelectedItem == "Steady") {
                updateKeys(shouldUpdateKeys: false)
            } else if (currentKeyMode.titleOfSelectedItem == "Reactive") {
                updateReactiveColors(shouldUpdateKeys: false)
            }
        }
    }
    
    @IBAction func setColor(_ sender: NSTextField) {
        let color = NSColor(hexString: sender.stringValue)
        ColorController.shared.setColor(color)
        view.window?.makeFirstResponder(view)
        
        if (currentKeyMode.titleOfSelectedItem == "Steady") {
            updateKeys(shouldUpdateKeys: true)
        } else if (currentKeyMode.titleOfSelectedItem == "Reactive") {
            updateReactiveColors(shouldUpdateKeys: true)
        }

        
    }
    
    func updateColorWheel(redrawCrosshair: Bool = true) {
        colorWheelView.setColor(ColorController.shared.selectedColor, redrawCrosshair)
    }
    
    func updateLabel() {
        colorLabel.backgroundColor = ColorController.shared.selectedColor
        colorLabel.stringValue = "#"+ColorController.shared.selectedColor.rgbHexString
        //colorLabel.textColor = RGB(r: 17, g: 17, b: 18).nsColor
    }
    
    private func updateReactiveColors(shouldUpdateKeys: Bool) {
        if (ColorController.shared.reactionModeSelected != nil) {
            for selected in ColorController.shared.reactionModeSelected! {
                (selected as! CustomColorWell).color = ColorController.shared.selectedColor
            }
        }
        updateKeys(shouldUpdateKeys: shouldUpdateKeys)
    }
    
    func updateSlider() {
        guard let sliderCell = brightnessSlider.cell as? GradientSliderCell else { fatalError() }
        sliderCell.colorA = ColorController.shared.masterColor
        brightnessSlider.drawCell(sliderCell)
        brightnessSlider.doubleValue = brightnessSlider.maxValue - (Double(ColorController.shared.brightness) *
            brightnessSlider.maxValue)
    }
    
    func updateKeys(shouldUpdateKeys: Bool) {
        if (KeyboardManager.shared.keysSelected != nil) {
            if (KeyboardManager.shared.keyboardManager.getKeyboardModel() != ThreeRegion && KeyboardManager.shared.keysSelected!.count > 0) {
                if (currentKeyMode.titleOfSelectedItem == "Steady") {
                    for key in KeyboardManager.shared.keysSelected! {
                        (key as! KeysView).setSteady(newColor: ColorController.shared.selectedColor)
                    }
                    // Will only set color when the mouse is up
                    if (shouldUpdateKeys) {
                        // Will notify for keyboard GS65 and other PerKey to update the keys once mouse is up
                        KeyboardManager.shared.keyboardView.updateKeys()
                    }
                
                } else if (currentKeyMode.titleOfSelectedItem == "Reactive") {
                    for key in KeyboardManager.shared.keysSelected! {
                        (key as! KeysView).setReactive(active: activeColor.color, rest: restColor.color, speed: UInt16(speedSlider.intValue))
                    }
                    
                    // Will only set color when the mouse is up
                    if (shouldUpdateKeys) {
                        // Will notify for keyboard GS65 and other PerKey to update the keys once mouse is up
                        KeyboardManager.shared.keyboardView.updateKeys()
                    }
                } else if (currentKeyMode.titleOfSelectedItem == "Disabled") {
                    for key in KeyboardManager.shared.keysSelected! {
                        (key as! KeysView).setDisabled()
                    }
    
                    // Will only set color when the mouse is up
                    if (shouldUpdateKeys) {
                        // Will notify for keyboard GS65 and other PerKey to update the keys once mouse is up
                        KeyboardManager.shared.keyboardView.updateKeys()
                    }
                }
            } else {
                // Three Region Keyboard
            }
        }
    }
}

extension NSView {
    func roundCorners(cornerRadius: Double) {
        self.wantsLayer = true
        self.layer?.cornerRadius = CGFloat(cornerRadius)
        self.layer?.masksToBounds = true
    }
}

extension ColorPickerController: ColorWheelViewDelegate {
    /// - postcondition: Mutates `ColorController.masterColor`
    func colorDidChange(_ newColor: NSColor, shouldUpdateKeyboard: Bool) {
        ColorController.shared.masterColor = newColor
        updateLabel()
        updateSlider()
        if (KeyboardManager.shared.keyboardManager.getKeyboardModel() != ThreeRegion) {
            if (currentKeyMode.titleOfSelectedItem == "Steady") {
                updateKeys(shouldUpdateKeys: shouldUpdateKeyboard)
            } else if (currentKeyMode.titleOfSelectedItem == "Reactive") {
                updateReactiveColors(shouldUpdateKeys: shouldUpdateKeyboard)
            }
        }
    }
}

extension ColorPickerController: NSControlTextEditingDelegate {
    
    private func validateControlString(_ string: String) -> Bool {
        // String must be 6 characters and only contain numbers and letters 'a' through 'f',
        // or 7 characters if the first character is '#'
        switch string.count {
        case 6:
            guard string.containsOnlyHexCharacters else { return false }
            return true
        case 7:
            guard string.hasPrefix("#") else { return false }
            var trimmed = string; trimmed.remove(at: trimmed.startIndex)
            guard trimmed.containsOnlyHexCharacters else { return false }
            return true
        default:
            return false
        }
    }
    
    func control(_ control: NSControl, isValidObject obj: Any?) -> Bool {
        if control == colorLabel {
            guard let string = obj as? String else { return false }
            return validateControlString(string)
        }
        return false
    }
}

extension String {
    var containsOnlyHexCharacters: Bool {
        return !contains {
            switch $0 {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "a", "b",
                 "c", "d", "e", "f":
                return false
            default:
                return true
            }
        }
    }
}
