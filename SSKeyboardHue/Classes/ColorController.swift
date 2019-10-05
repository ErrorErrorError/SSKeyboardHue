//
//  ColorController.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/4/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

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
    }}
