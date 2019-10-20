//
//  ColorController.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/4/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
// 

import Cocoa

class KeyboardManager {
    static var shared = KeyboardManager()
    var keyboardManager: SSKeyboardWrapper!
    weak var keyboardView: KeyboardView!
    var keysSelected: NSMutableArray? = NSMutableArray()
}

class ColorController {
    static var shared = ColorController()
    // Should only be set by `colorPicker`'s `NSSlider`. Affects `selectedColor`.
    var brightness: CGFloat = 1.0 {
        didSet {
            selectedColor = NSColor(calibratedHue: masterColor.hueComponent,
                                    saturation: masterColor.saturationComponent,
                                    brightness: brightness,
                                    alpha: 1.0)
        }
    }
    // Should only be set by `colorPicker`'s `ColorWheelView`. Affects `selectedColor`.
    var masterColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) {
        didSet {
            selectedColor = NSColor(calibratedHue: masterColor.hueComponent,
                                    saturation: masterColor.saturationComponent,
                                    brightness: selectedColor.brightnessComponent,
                                    alpha: 1.0)
        }
    }
    
    var selectedColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    // Injected by ColorPickerViewController
    weak var colorPicker: ColorPickerController!
    /// - postcondition: Mutates `colorPicker`
    
    // This changes the color picker based on current key
    func setKey(key: KeysWrapper) {
        if (key.getMode() == Steady) {
            setColor(key.getMainColor().nsColor)
            colorPicker.currentKeyMode.selectItem(withTitle: "Steady")
            colorPicker.setKeyMode(colorPicker.currentKeyMode)
        } else if (key.getMode() == Reactive) {
            setColor(RGB(r: 0xff, g: 0xff, b: 0xff).nsColor)
            colorPicker.activeColor.color = key.getActiveColor().nsColor
            colorPicker.restColor.color = key.getMainColor().nsColor
            colorPicker.speedSlider.intValue = Int32(key.getSpeed())
            colorPicker.currentKeyMode.selectItem(withTitle: "Reactive")
            colorPicker.setKeyMode(colorPicker.currentKeyMode)
        } else if (key.getMode() == Disabled) {
            setColor(key.getMainColor().nsColor)
            colorPicker.currentKeyMode.selectItem(withTitle: "Disabled")
            colorPicker.setKeyMode(colorPicker.currentKeyMode)
        }
    }
    // If reactionMode is selected
    var reactionModeSelected: NSMutableArray? = NSMutableArray(capacity: 2)

    func setColor(_ color: NSColor) {
        selectedColor = color
        brightness = color.scaledBrightness
        masterColor = NSColor(calibratedHue: color.hueComponent,
                              saturation: color.saturationComponent,
                              brightness: 1.0,
                              alpha: 1.0)
        colorPicker.updateColorWheel()
        colorPicker.updateSlider()
        colorPicker.updateLabel()
        colorPicker.updateKeys(shouldUpdateKeys: true)
    }
}
