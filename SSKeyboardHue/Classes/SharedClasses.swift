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
    var effectsArray: NSMutableArray? = NSMutableArray()
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
            if (reactionBoxColors!.count > 0) {
                for colorBox in reactionBoxColors! {
                    let color = colorBox as! CustomColorWell
                    color.removeSelected()
                }
            }
            
            setColor(RGB(r: 0xff, g: 0xff, b: 0xff).nsColor)
            colorPicker.activeColor.color = key.getActiveColor().nsColor
            colorPicker.restColor.color = key.getMainColor().nsColor
            colorPicker.speedSlider.intValue = Int32(key.getSpeed())
            var trimmed = colorPicker.speedSlider.intValue.description
            trimmed.removeLast(2)
            colorPicker.speedBox.string = trimmed + "s"
            colorPicker.currentKeyMode.selectItem(withTitle: "Reactive")
            colorPicker.setKeyMode(colorPicker.currentKeyMode)
        } else if (key.getMode() == ColorShift) {
            if (transitionThumbColors!.count > 0) {
                for sliders in transitionThumbColors! {
                    let thumb = sliders as! SliderThumb
                    thumb.removeSelected()
                }
            }
            
            let findEffectId = key.getEffectId()
            var keyEffect: KeyEffectWrapper = KeyEffectWrapper()
            for effects in KeyboardManager.shared.effectsArray! {
                let effect = effects as! KeyEffectWrapper
                if (effect.getEffectId() == findEffectId) {
                    keyEffect = effect
                    break
                }
            }
            
            var totalDuration: Int32 = 0
            let transitions = UnsafeMutablePointer<KeyTransition>(keyEffect.getTransitions())
            for i in 0..<keyEffect.getTransitionSize() {
                totalDuration += Int32(transitions![Int(i)].duration)
            }
            
            setColor(RGB(r: 0xff, g: 0xff, b: 0xff).nsColor)
            colorPicker.speedSlider.intValue = totalDuration
            colorPicker.multiGradientSlider.setThumbsFromTransitions(transitions: transitions!, count: Int(keyEffect.getTransitionSize()))
            var trimmed = colorPicker.speedSlider.intValue.description
            trimmed.removeLast(2)
            colorPicker.speedBox.string = trimmed + "s"
            colorPicker.currentKeyMode.selectItem(withTitle: "ColorShift")
            colorPicker.setKeyMode(colorPicker.currentKeyMode)

        } else if (key.getMode() == Disabled) {
            setColor(key.getMainColor().nsColor)
            colorPicker.currentKeyMode.selectItem(withTitle: "Disabled")
            colorPicker.setKeyMode(colorPicker.currentKeyMode)
        }
    }
    // If reactionMode is selected
    var reactionBoxColors: NSMutableArray? = NSMutableArray(capacity: 2)
    
    var transitionThumbColors: NSMutableArray? = NSMutableArray()

    // This is called only if user wants to change the color of the color picker controller
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
        colorPicker.updateKeys(shouldUpdateKeys: false)
    }
}
