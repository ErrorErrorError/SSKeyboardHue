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
    @IBOutlet weak var activeColor: CustomColorWell!
    @IBOutlet weak var activeText: NSTextField!
    @IBOutlet weak var restColor: CustomColorWell!
    @IBOutlet weak var restText: NSTextField!
    @IBOutlet weak var multiGradientSlider: MultiGradientSlider!
    @IBOutlet weak var waveModeCheckBox: NSButton!
    @IBOutlet weak var setOriginButton: NSButton!
    @IBOutlet weak var waveDirectionSegment: NSSegmentedControl!
    @IBOutlet weak var waveRadType: NSSegmentedControl!
    @IBOutlet weak var waveLengthSlider: NSSlider!
    @IBOutlet weak var speedSlider: NSSlider!
    @IBOutlet weak var speedText: NSTextField!
    @IBOutlet weak var speedBox: NSTextField!
    @IBOutlet weak var pulseText: NSTextField!
    @IBOutlet weak var pulseDurationLabel: NSTextField!
    
    weak var delegate: ColorPickerControllerDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        
        // Delegates
        colorWheelView.delegate = self
        multiGradientSlider.delegate = self
        ColorController.shared.colorPicker = self
        
        colorLabel.roundCorners(cornerRadius: 10.0)
        colorLabel.layer?.backgroundColor = textViewBackground.nsColor.cgColor
        colorLabel.isBezeled = false
        
        currentKeyMode.addItem(withTitle: "Steady")
        currentKeyMode.addItem(withTitle: "ColorShift")
        currentKeyMode.addItem(withTitle: "Breathing")
        currentKeyMode.addItem(withTitle: "Reactive")
        currentKeyMode.addItem(withTitle: "Disabled")
        currentKeyMode.addItem(withTitle: "Mixed")
        currentKeyMode.menu?.item(at: 5)?.isHidden = true   // Mixed
        
        setUpReactiveViews()
        setupWaveViews()        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        ColorController.shared.gradientViewPoint.delegate = self

    }
    
    private func setupWaveViews() {
        waveDirectionSegment.selectedSegment = 1
        waveRadType.selectedSegment = 0
    }
    
    override func viewWillAppear() {
       view.layer?.backgroundColor = colorBackground.nsColor.cgColor
        ColorController.shared.setColor(NSColor.white.usingColorSpace(.genericRGB)!)
    }

    
    private func setUpReactiveViews() {
        
        activeColor.color = RGB(r: 0xff, g: 0x00, b: 0x00).nsColor
        activeColor.roundCorners(cornerRadius: 5.0)
                
        restColor.color = RGB(r: 0x00, g: 0x00, b: 0x00).nsColor
        restColor.roundCorners(cornerRadius: 5.0)
        
        speedSlider.minValue = 100
        speedSlider.maxValue = 1000
        speedSlider.intValue = 300
        
        var trimmed = speedSlider.intValue.description
        trimmed.removeLast(2)
        speedBox.stringValue = trimmed + "s"
    }
    
    private func showReactive(show: Bool, fromKey:Bool) {
        let isHidden = (show) ? false : true
        activeColor.isHidden = isHidden
        restColor.isHidden = isHidden
        activeText.isHidden = isHidden
        restText.isHidden = isHidden
        speedSlider.isHidden = isHidden
        speedText.isHidden = isHidden
        speedBox.isHidden = isHidden
        if(show) {
            speedSlider.minValue = 100
            speedSlider.maxValue = 1000
            
            if (!fromKey) {
                speedSlider.intValue = 300
                ColorController.shared.setColor(NSColor.white.usingColorSpace(.genericRGB)!)
                activeColor.color = RGB(r: 0xff, g: 0x0, b: 0x0).nsColor
                restColor.color = RGB(r: 0x0, g: 0x0, b: 0x0).nsColor
            }
            updateSpeedSliderValue()
        }
    }
    
    private func showColorShift(show: Bool, fromKey: Bool) {
        let isHidden = (show) ? false : true
        multiGradientSlider.isHidden = isHidden
        speedSlider.isHidden = isHidden
        speedText.isHidden = isHidden
        speedBox.isHidden = isHidden
        waveModeCheckBox.isHidden = isHidden
        setOriginButton.isHidden = isHidden
        waveDirectionSegment.isHidden = isHidden
        waveRadType.isHidden = isHidden
        waveLengthSlider.isHidden = isHidden
        pulseText.isHidden = isHidden
        pulseDurationLabel.isHidden = isHidden
        if (!ColorController.shared.gradientViewPoint.isHidden) {
            ColorController.shared.gradientViewPoint.isHidden = true
        }
        
        if(show) {
            speedSlider.minValue = 100
            speedSlider.maxValue = 3000
            
            if (!fromKey) {
                speedSlider.intValue = 300
                waveModeCheckBox.state = .off
                enableWavemode(enable: false)
                ColorController.shared.setColor(NSColor.white.usingColorSpace(.genericRGB)!)
                waveDirectionSegment.selectedSegment = Int(Inward.rawValue)
                waveLengthSlider.integerValue = 100
                waveRadType.selectedSegment = Int(XY.rawValue)
                ColorController.shared.gradientViewPoint.setDefaultView()
            }
            updateSpeedSliderValue()
            
            var trimmed = waveLengthSlider.intValue.description
            trimmed.removeLast(1)
            pulseDurationLabel.stringValue = trimmed
            multiGradientSlider.setGradientMode(colorShiftOrBreathing: ColorShift, fromKey: fromKey)
            multiGradientSlider.maxSize = 14
        }
        
    }
        
    private func showBreathing(show: Bool, fromKey: Bool) {
        let isHidden = (show) ? false : true
        multiGradientSlider.isHidden = isHidden
        speedSlider.isHidden = isHidden
        speedText.isHidden = isHidden
        speedBox.isHidden = isHidden
        if (show) {
            speedSlider.minValue = 200
            speedSlider.maxValue = 3000
            
            if (!fromKey) {
                speedSlider.intValue = 400
                ColorController.shared.setColor(NSColor.white.usingColorSpace(.genericRGB)!)
            }
            updateSpeedSliderValue()
            multiGradientSlider.setGradientMode(colorShiftOrBreathing: Breathing, fromKey: fromKey)
            multiGradientSlider.maxSize = 4
        }
    }
    
    private func updateSpeedSliderValue() {
        var trimmed = speedSlider.intValue.description
        trimmed.removeLast(2)
        speedBox.stringValue = trimmed + "s"
    }
    
    public func setMode(mode: PerKeyModes, fromKey: Bool) {
        if (currentKeyMode.indexOfSelectedItem != mode.rawValue) {
            currentKeyMode.selectItem(at: Int(mode.rawValue))
        }
        resetSelectedItems()
        if (mode == Reactive) {
            disableViews(shouldDisable: false)
            showColorShift(show: false, fromKey: false)
            showBreathing(show: false, fromKey: false)
            showReactive(show: true, fromKey: fromKey)
        } else if (mode == ColorShift) {
            disableViews(shouldDisable: false)
            showReactive(show: false, fromKey: false)
            showBreathing(show: false, fromKey: false)
            showColorShift(show: true, fromKey: fromKey)
        } else if (mode == Breathing) {
            disableViews(shouldDisable: false)
            showColorShift(show: false, fromKey: false)
            showReactive(show: false, fromKey: false)
            showBreathing(show: true, fromKey: fromKey)
        } else {
            showReactive(show: false, fromKey: false)
            showColorShift(show: false, fromKey: false)
            showBreathing(show: false, fromKey: false)
            disableViews(shouldDisable: false)
            if (mode == Steady && !fromKey) {
                ColorController.shared.setColor(NSColor.red.usingColorSpace(.deviceRGB)!)
            } else if (mode == Disabled || mode.rawValue == 5) {
                disableViews(shouldDisable: true)
                ColorController.shared.setColor(NSColor.white.usingColorSpace(.genericRGB)!)
            }
        }
        
        updateKeys(shouldUpdateKeys: fromKey ? false : true)
    }
    
    private func disableViews(shouldDisable: Bool) {
        if (shouldDisable) {
            colorLabel.isEnabled = false
            brightnessSlider.isEnabled = false
            colorWheelView.isEnabled = false
        } else {
            colorLabel.isEnabled = true
            brightnessSlider.isEnabled = true
            colorWheelView.isEnabled = true
        }
    }
    
    @IBAction func currentMode(_ sender: NSPopUpButtonCell) {
        setMode(mode: PerKeyModes(UInt32(sender.indexOfSelectedItem)), fromKey: false)
    }
    
    @IBAction func setSpeed(_ sender: NSSlider) {
        updateSpeedSliderValue()
        let shouldSendKeyCommand = (NSApplication.shared.currentEvent?.type == NSEvent.EventType.leftMouseUp) ? true : false
        updateKeys(shouldUpdateKeys: shouldSendKeyCommand)
    }
        
    @IBAction func setBrightness(_ sender: NSSlider) {
        ColorController.shared.brightness = CGFloat((sender.maxValue-sender.doubleValue) / sender.maxValue)
        updateColorWheel(redrawCrosshair: false)
        updateLabel()
        let shouldSendKeyCommand = (NSApplication.shared.currentEvent?.type == NSEvent.EventType.leftMouseUp) ? true : false
        if (!shouldSendKeyCommand) {
            updateKeys(shouldUpdateKeys: false)
            return
        }
        updateKeys(shouldUpdateKeys: true)
    }
    
    @IBAction func setColor(_ sender: NSTextField) {
        let color = NSColor(hexString: sender.stringValue)
        ColorController.shared.setColor(color)
        view.window?.makeFirstResponder(view)
        updateKeys(shouldUpdateKeys: true)
    }
    
    @IBAction func setWaveModeClicked(_ sender: NSButton) {
        enableWavemode(enable: sender.state == .on)
        updateKeys(shouldUpdateKeys: true)
    }
    
    @IBAction func setWaveRadiationControl(_ sender: Any) {
        updateKeys(shouldUpdateKeys: true)
    }
    
    @IBAction func setWaveDirection(_ sender: Any) {
        updateKeys(shouldUpdateKeys: true)
    }
    
    @IBAction func setOriginButtonClicked(_ sender: NSButton) {
        delegate?.buttonHasClicked(sender)
    }
    
    @IBAction func setWaveSpeed(_ sender: NSSlider) {
        var trimmed = waveLengthSlider.intValue.description
        trimmed.removeLast(1)
        pulseDurationLabel.stringValue = trimmed

        let shouldSendKeyCommand = (NSApplication.shared.currentEvent?.type == NSEvent.EventType.leftMouseUp) ? true : false
        updateKeys(shouldUpdateKeys: shouldSendKeyCommand)
    }
    
    @IBAction func presetsButtonPressed(_ sender: NSButton) {
        NotificationCenter.default.post(name: .shouldShowPresets, object: nil)
    }
        
    func enableWavemode(enable: Bool) {
        setOriginButton.isEnabled = enable
        waveLengthSlider.isEnabled = enable
        waveDirectionSegment.isEnabled = enable
        waveRadType.isEnabled = enable
        if (!ColorController.shared.gradientViewPoint.isHidden) {
            ColorController.shared.gradientViewPoint.isHidden = true
        }
    }
    
    func updateColorWheel(redrawCrosshair: Bool = true) {
        colorWheelView.setColor(ColorController.shared.selectedColor, redrawCrosshair)
    }
    
    func updateLabel() {
        colorLabel.backgroundColor = ColorController.shared.selectedColor
        colorLabel.stringValue = "#"+ColorController.shared.selectedColor.rgbHexString
    }
    
    func updateSlider() {
        guard let sliderCell = brightnessSlider.cell as? GradientSliderCell else { fatalError() }
        sliderCell.colorA = ColorController.shared.masterColor
        brightnessSlider.drawCell(sliderCell)
        brightnessSlider.doubleValue = brightnessSlider.maxValue - (Double(ColorController.shared.brightness) *
            brightnessSlider.maxValue)
    }
    
    /// This method updates the key views and the keyboard depending if tehre was views changed
    /// - Parameter shouldUpdateKeys: if the mouseup is called, then it will update the keyboard
    func updateKeys(shouldUpdateKeys: Bool) {
        // This checks if there was change in key views. This prevents keyboard from updating if the keys are the same
        var isThereChange = false
        if (KeyboardManager.shared.keyboardManager.getKeyboardModel() != ThreeRegion) {
            if (currentKeyMode.titleOfSelectedItem == "Steady") {
                for key in KeyboardManager.shared.keysSelected {
                    (key as! KeysView).setSteady(newColor: ColorController.shared.selectedColor)
                    isThereChange = true
                }
            } else if (currentKeyMode.titleOfSelectedItem == "Reactive") {
                for selected in ColorController.shared.reactionBoxColors {
                    (selected as! CustomColorWell).color = ColorController.shared.selectedColor
                }
                
                for key in KeyboardManager.shared.keysSelected {
                    (key as! KeysView).setReactive(active: activeColor.color, rest: restColor.color, speed: UInt16(speedSlider.intValue))
                    isThereChange = true
                }
                
            } else if (currentKeyMode.titleOfSelectedItem == "ColorShift"){
                // Sets Transition color if was changed
                for transition in ColorController.shared.transitionThumbColors {
                    (transition as! SliderThumb).color = ColorController.shared.selectedColor
                }
                
                // Updates duration if speed changed
                for transition in multiGradientSlider.getSubviewsInOrder() {
                    transition.calcDuration()
                }
                
                var colorArray: [NSColor] = []
                for i in multiGradientSlider.getTransitionArray() {
                    colorArray.append(i.color.nsColor)
                }
                
                ColorController.shared.gradientViewPoint.colorArray = colorArray
                
                ColorController.shared.gradientViewPoint.typeOfRad = WaveRadControl(rawValue: UInt32(waveRadType!.selectedSegment))
                
                if (shouldUpdateKeys) {
                    let keyEffect = getKeyEffect(isColorShift: true)
                    for key in KeyboardManager.shared.keysSelected {
                        if ((key as! KeysView).keyModel.getEffectId() != keyEffect.getEffectId()) {
                            (key as! KeysView).setEffectKey(_id: keyEffect.getEffectId(), mode: ColorShift, color: keyEffect.getStartColor().nsColor)
                            isThereChange = true
                        }
                    }
                }
                
            } else if (currentKeyMode.titleOfSelectedItem == "Breathing") {
                for transition in ColorController.shared.transitionThumbColors {
                    (transition as! SliderThumb).color = ColorController.shared.selectedColor
                }
                
                // Updates duration if speed changed
                for transition in multiGradientSlider.getSubviewsInOrder() {
                    transition.calcDuration()
                }
                
                if (shouldUpdateKeys) {
                    let keyEffect = getKeyEffect(isColorShift: false)
                    for key in KeyboardManager.shared.keysSelected {
                        if ((key as! KeysView).keyModel.getEffectId() != keyEffect.getEffectId()) {
                            (key as! KeysView).setEffectKey(_id: keyEffect.getEffectId(), mode: Breathing, color: keyEffect.getStartColor().nsColor)
                            isThereChange = true
                        }
                    }
                }
            } else if (currentKeyMode.titleOfSelectedItem == "Disabled") {
                for key in KeyboardManager.shared.keysSelected {
                    (key as! KeysView).setDisabled()
                    isThereChange = true
                }
            }
            
            /// Removes unused effects
            removeUnusedEffects()
        } else {
            // TODO - Three Region Keyboard
        }
        
        // Will only set color when the mouse is up
        if (shouldUpdateKeys && isThereChange) {
            // Will notify for keyboard GS65 and other PerKey to update the keys once mouse is up
            KeyboardManager.shared.keyboardView.updateKeys()
        }
    }
    
    func isCurrentModeEqual(key: KeysWrapper) -> Bool {
        var isModeEqual = false
        isModeEqual = currentKeyMode.indexOfSelectedItem == key.getMode().rawValue
        if (!isModeEqual) {
            return false
        }
        
        if (key.getMode() == Steady) {
            isModeEqual = key.getMainColor() == ColorController.shared.selectedColor.getRGB
        } else if (key.getMode() == Reactive) {
            isModeEqual = key.getMainColor() == restColor.color.getRGB && key.getActiveColor() == activeColor.color.getRGB
            if (isModeEqual) {
                isModeEqual = key.getSpeed() == speedSlider.intValue
            }
        } else if (key.getMode() == ColorShift || key.getMode() == Breathing) {
            let effectId = key.getEffectId()
            let effect = KeyboardManager.shared.effectsArray.filter { (singleEffect) -> Bool in
                return (singleEffect as! KeyEffectWrapper).getEffectId() == effectId
                }[0] as! KeyEffectWrapper
            let multiArray = (key.getMode() == ColorShift) ? multiGradientSlider.getTransitionArray() : multiGradientSlider.getTransitionArrayBreathing()
            isModeEqual = effect.getTransitionSize() == multiArray.count
            
            if (isModeEqual) {
                var index = 0
                var totalduration: UInt16 = 0
                while (isModeEqual && index < effect.getTransitionSize()) {
                    let transitionEffect = effect.getTransitions()[index]
                    let transitionMulti = multiArray[index]
                    isModeEqual = transitionEffect.color == transitionMulti.color && transitionEffect.duration == transitionMulti.duration
                    if (isModeEqual) {
                        totalduration += transitionEffect.duration
                    }
                    index += 1
                }
                
                if(isModeEqual) {
                    isModeEqual = totalduration == speedSlider.integerValue
                }
                
                if (isModeEqual) {
                    if (key.getMode() == ColorShift && effect.isWaveModeActive()) {
                        isModeEqual = effect.getWaveRadControl().rawValue == waveRadType.selectedSegment && effect.getWaveLength() == waveLengthSlider.integerValue && effect.getWaveDirection().rawValue == waveDirectionSegment.integerValue && effect.getWaveOrigin().x == ColorController.shared.gradientViewPoint.getCalculatedOrigin().x && effect.getWaveOrigin().y == ColorController.shared.gradientViewPoint.getCalculatedOrigin().y
                    } else {
                        isModeEqual = true
                    }
                }
            }
        }
                
        return isModeEqual
    }
    
    func setMixedMode(shouldSet: Bool) {
        if (shouldSet) {
            if (currentKeyMode.indexOfSelectedItem != 5) {
                setMode(mode: PerKeyModes(rawValue: 5), fromKey: true)
            }
        } else {
            // default to steady
            setMode(mode: Steady, fromKey: true)
        }
    }
    
    private func removeUnusedEffects() {
        let usedEffectId = KeyboardManager.shared.keyboardView.getUsedEffectId()
        
        for effects in KeyboardManager.shared.effectsArray {
            let effect = (effects as! KeyEffectWrapper)
            let contains = usedEffectId.contains(effect.getEffectId())
            if (!contains) {
                KeyboardManager.shared.effectsArray.remove(effect)
            }
        }
    }
    
    private func resetSelectedItems() {
        for i in ColorController.shared.reactionBoxColors {
            (i as! CustomColorWell).removeSelected()
        }
        
        for i in ColorController.shared.transitionThumbColors {
            (i as! SliderThumb).removeSelected()
        }
    }
    
    private func getKeyEffect(isColorShift: Bool) -> KeyEffectWrapper {
        var id: UInt8 = 1
        let usedEffectId = KeyboardManager.shared.keyboardView.getUsedEffectId()
        for i in 1...255 {
            let containsId = usedEffectId.contains(UInt8(i))
            if (!containsId) {
                id = UInt8(i)
                break
            }
        }
        
        var transitions: [KeyTransition]
        if (isColorShift) {
            transitions = multiGradientSlider.getTransitionArray()
        } else {
            transitions = multiGradientSlider.getTransitionArrayBreathing()
        }
        
        let keyEffect = KeyEffectWrapper(keyEffect: id, &transitions, UInt8(transitions.count))
        
        if (waveModeCheckBox.state == .on) {
            let keypoint = ColorController.shared.gradientViewPoint.getCalculatedOrigin()
            keyEffect?.setWaveMode(keypoint, UInt16(waveLengthSlider.integerValue), WaveRadControl(rawValue: UInt32(waveRadType!.selectedSegment)), WaveDirection(rawValue: UInt32(waveDirectionSegment!.selectedSegment)))
        } else {
            keyEffect?.disableWavemode()
        }
        
        for effects in KeyboardManager.shared.effectsArray {
            let effect = (effects as! KeyEffectWrapper)
            if (effect.isEqual(keyEffect)) {
                return effect
            }
        }
        
        /// Will add new effect to array if there was no same effects found
        KeyboardManager.shared.effectsArray.add(keyEffect!)
        
        return keyEffect!
    }
}

protocol ColorPickerControllerDelegate: class {
    func buttonHasClicked(_ button: NSButton)
}

extension NSView {
    func roundCorners(cornerRadius: Double) {
        self.wantsLayer = true
        self.layer?.cornerRadius = CGFloat(cornerRadius)
        self.layer?.masksToBounds = true
    }
}

//This get's called if the colorWheelView's picker is moved.
extension ColorPickerController: ColorWheelViewDelegate {
    /// - postcondition: Mutates `ColorController.masterColor`
    func colorDidChange(_ newColor: NSColor, shouldUpdateKeyboard: Bool) {
        ColorController.shared.masterColor = newColor
        updateLabel()
        updateSlider()
        updateKeys(shouldUpdateKeys: shouldUpdateKeyboard)
    }
}

extension ColorPickerController: MultiGradientSliderDelegate {
    func viewDidChange(_ sliderThumb: SliderThumb, updateView : Bool) {
        updateKeys(shouldUpdateKeys: updateView)
    }
}

extension ColorPickerController: GradientViewPointPickerDelegate {
    func newValueUpdated(calcVal: KeyPoint) {
        updateKeys(shouldUpdateKeys: true)
    }
}

extension Notification.Name {
    static let shouldShowPresets = Notification.Name("shouldShowPresets")
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
