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
    @IBOutlet weak var presetsTableView: NSTableView!
    @IBOutlet weak var presetDeleteButton: NSButton!
    @IBOutlet weak var presetsLabel: NSTextField!
    @IBOutlet weak var multiGradientSlider: MultiGradientSlider!
    @IBOutlet weak var waveModeCheckBox: NSButton!
    @IBOutlet weak var setOriginButton: NSButton!
    @IBOutlet weak var waveDirectionPopup: NSPopUpButton!
    @IBOutlet weak var waveLengthSlider: NSSlider!
    
    var filesList: [URL] = []
    var selectedFile: URL! {
        didSet {
            if (self.selectedFile != nil) {
                setKeyboardColorFromFile()
            }
        }
    }
    
    // Reactive View
    var activeColor: CustomColorWell!
    var restColor: CustomColorWell!
    var activeText: NSTextView!
    var restText: NSTextView!
    var speedSlider: NSSlider!
    var speedText: NSTextView!
    var speedBox: NSTextView!
    
    var presetsTableRect: NSRect!
    var speedRect: NSRect!
    var speedBoxRect: NSRect!
    var speedTextRect: NSRect!
    var presetsLabelRect: NSRect!
    
    var shiftDown: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
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
        setUpReactiveViews()
        checkForPresets()
        presetDeleteButton.isEnabled = false
    }
    
    override func viewWillAppear() {
        view.layer?.backgroundColor = colorBackground.nsColor.cgColor
        view.roundCorners(cornerRadius: 10.0)
        ColorController.shared.setColor(NSColor.white.usingColorSpace(.genericRGB)!)
    }

    func checkForPresets() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let directoryPath = docURL.appendingPathComponent("presets")
        
        if FileManager.default.fileExists(atPath: directoryPath.absoluteString) {
            filesList = contentsOf(folder: directoryPath)
            self.presetsTableView.reloadData()
        }
    }
    
    func contentsOf(folder: URL) -> [URL] {
        
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: .none, options: .skipsHiddenFiles)
            return contents
        } catch {
            return []
        }
    }
    
    private func setKeyboardColorFromFile() {
        let data = try? Data(contentsOf: selectedFile)
        let array = [UInt8](data!)
        
        if (KeyboardManager.shared.keyboardManager.getKeyboardModel() == PerKeyGS65 || KeyboardManager.shared.keyboardManager.getKeyboardModel() == PerKey) {
            var numKeys: Int
            if (KeyboardManager.shared.keyboardManager.getKeyboardModel() == PerKeyGS65) {
                numKeys = KeyboardLayout.keysGS65.count + KeyboardLayout.nullGS65Keys.count
            } else {
                numKeys = KeyboardLayout.keysPerKey.count + KeyboardLayout.nullPerKey.count
            }
            
            for i in 0..<(numKeys) {
                let keyViewArray = KeyboardManager.shared.keyboardView.subviews
                let currentIndex  = i * 12
                let region = array[currentIndex]
                let keycode = array[currentIndex + 1]
                let colorMain = RGB(r: array[currentIndex + 2], g: array[currentIndex + 3], b: array[currentIndex + 4])
                let colorActive = RGB(r: array[currentIndex + 5], g: array[currentIndex + 6], b: array[currentIndex + 7])
                let duration = UInt16(array[currentIndex + 9]) << 8 | UInt16(array[currentIndex + 8])
                let effectId = array[currentIndex + 10]
                let mode: PerKeyModes = PerKeyModes(rawValue: PerKeyModes.RawValue(array[currentIndex + 11]))
                let foundKeyArray = keyViewArray.filter {(findKey) -> Bool in
                    let castKey = findKey as! KeysView
                    return castKey.keyModel.getRegion() == region && castKey.keyModel.getKeyCode() == keycode
                }
                
                let keyFound = foundKeyArray[0] as! KeysView
                if (mode == Steady) {
                    keyFound.setSteady(newColor: colorMain.nsColor)
                } else if (mode == Reactive) {
                    keyFound.setReactive(active: colorActive.nsColor, rest: colorMain.nsColor, speed: duration)
                } else if (mode == ColorShift || mode == Breathing) {
                    keyFound.setEffectKey(_id: effectId, mode: mode)
                } else {
                    keyFound.setDisabled()
                }
            }
            
            // If there is any effects in the file, it will detect the effects and load them into the effects array.
            // Minimum effect size is 16 bytes
            if (array.count > (numKeys * 12)) {
                var startIndexEffect = (array.count - (array.count - (numKeys * 12)))
                var transitions: [KeyTransition] = []
                while (startIndexEffect < array.count) {
                    let effectId = array[startIndexEffect]
                    let transitionSize = array[startIndexEffect + 1]
                    for i in 0..<transitionSize {
                        let index: Int = (startIndexEffect + 2) + Int((i * 5))
                        let transitionColor = RGB(r: array[index], g: array[index + 1], b: array[index + 2])
                        let transitionDuration = UInt16(array[index + 4]) << 8 | UInt16(array[index + 3])
                        transitions.append(KeyTransition(color: transitionColor, duration: transitionDuration))
                    }
                    
                    startIndexEffect += Int((2 + (transitionSize * 5)))
                    let waveDirection = array[startIndexEffect]
                    let waveLength = UInt16(array[startIndexEffect + 2]) << 8 | UInt16(array[startIndexEffect + 1])
                    let wavePointX = UInt16(array[startIndexEffect + 4]) << 8 | UInt16(array[startIndexEffect + 3])
                    let wavePointY = UInt16(array[startIndexEffect + 6]) << 8 | UInt16(array[startIndexEffect + 5])
                    let wavePoint = KeyPoint(x: wavePointX, y: wavePointY)
                    let waveRadControl = array[startIndexEffect + 7]
                    let isWaveModeActive = array[startIndexEffect + 8]
                    
                    let keyEffect = KeyEffectWrapper(keyEffect: effectId, &transitions, transitionSize)
                    
                    if (isWaveModeActive == 1) {
                        keyEffect?.setWaveMode(wavePoint, waveLength, WaveRadControl(rawValue: WaveRadControl.RawValue(waveRadControl)), WaveDirection(rawValue: WaveDirection.RawValue(waveDirection)))
                    }
                    
                    let effectsArray = KeyboardManager.shared.effectsArray
                    for effects in effectsArray {
                        let effect = effects as! KeyEffectWrapper
                        if (effect.getEffectId() == effectId) {
                            effectsArray.remove(effect)
                        }
                    }
                    
                    KeyboardManager.shared.effectsArray.add(keyEffect!)
                    startIndexEffect += 9
                }
            }
            /// Find effect in array
        } else {
            /// TODO - Implement ThreeRegion
        }
        
        KeyboardManager.shared.keyboardView.updateKeys(forceRefresh: true)
    }
    
    private func setUpReactiveViews() {
        activeColor = CustomColorWell(frame: NSRect(origin: CGPoint(x: 22, y: 360), size: CGSize(width: 25, height: 25)))
        activeColor.color = RGB(r: 0xff, g: 0x00, b: 0x00).nsColor
        activeColor.roundCorners(cornerRadius: 5.0)
        activeColor.isHidden = true
        
        activeText = NSTextView(frame: NSRect(origin: CGPoint(x: 52, y: 352), size: CGSize(width: 45, height: 25)))
        activeText.isHidden = true
        activeText.string = "Active"
        activeText.isEditable = false
        activeText.textColor = NSColor.white
        
        restColor = CustomColorWell(frame: NSRect(origin: CGPoint(x: 116, y: 360), size: CGSize(width: 25, height: 25)))
        restColor.color = RGB(r: 0x00, g: 0x00, b: 0x00).nsColor
        restColor.roundCorners(cornerRadius: 5.0)
        restColor.isHidden = true
        
        restText = NSTextView(frame: NSRect(origin: CGPoint(x: 146, y: 352), size: CGSize(width: 35, height: 25)))
        restText.isHidden = true
        restText.string = "Rest"
        restText.isEditable = false
        restText.textColor = NSColor.white
        
        speedRect = NSRect(x: 16, y: 310, width: 170, height: 20)
        speedSlider = NSSlider(frame: speedRect)
        speedSlider.isHidden = true
        speedSlider.minValue = 100
        speedSlider.maxValue = 1000
        speedSlider.cell!.target = self
        speedSlider.cell!.action = #selector(setSpeed(_:))
        speedSlider.intValue = 300
        
        speedTextRect = NSRect(x:14, y: 332, width: 55, height: 10)
        speedText = NSTextView(frame: speedTextRect)
        speedText.isHidden = true
        speedText.string = "Speed"
        speedText.isEditable = false
        speedText.textColor = NSColor.white
        
        speedBoxRect = NSRect(x: 188, y: 313, width: 55, height: 10)
        speedBox = NSTextView(frame: speedBoxRect)
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
            }
            updateSpeedSliderValue()
            
            shiftDown = 80
            presetsTableView.superview?.superview!.frame = NSRect(x: (presetsTableView.superview?.superview!.frame.origin.x)!, y: (presetsTableView.superview?.superview!.frame.origin.y)!, width: presetsTableRect.width, height: presetsTableRect.height - shiftDown)
            
            speedSlider.frame.origin.y = speedRect.origin.y
            speedBox.frame.origin.y = speedBoxRect.origin.y
            speedText.frame.origin.y = speedTextRect.origin.y
            presetsLabel.frame.origin.y = presetsLabelRect.origin.y - shiftDown
            presetDeleteButton.frame.origin.y = presetsLabelRect.origin.y - shiftDown
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
        waveDirectionPopup.isHidden = isHidden
        waveLengthSlider.isHidden = isHidden
        
        if(show) {
            speedSlider.minValue = 100
            speedSlider.maxValue = 3000
            if (!fromKey) {
                speedSlider.intValue = 300
                waveModeCheckBox.state = .off
            }
            updateSpeedSliderValue()
            
            shiftDown = 210
            speedSlider.frame.origin.y = speedRect.origin.y - 26
            speedBox.frame.origin.y = speedBoxRect.origin.y - 26
            speedText.frame.origin.y = speedTextRect.origin.y - 26
            presetsLabel.frame.origin.y = presetsLabelRect.origin.y - shiftDown
            presetDeleteButton.frame.origin.y = presetsLabelRect.origin.y - shiftDown
            
            presetsTableView.superview?.superview!.frame = NSRect(x: (presetsTableView.superview?.superview!.frame.origin.x)!, y: (presetsTableView.superview?.superview!.frame.origin.y)!, width: presetsTableRect.width, height: presetsTableRect.height - shiftDown)
            multiGradientSlider.setGradientMode(colorShiftOrBreathing: ColorShift, fromKey: fromKey)
        } else {
            waveModeCheckBox.state = .off
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
            }
            updateSpeedSliderValue()
            
            shiftDown = 120
            speedSlider.frame.origin.y = speedRect.origin.y - 26
            speedBox.frame.origin.y = speedBoxRect.origin.y - 26
            speedText.frame.origin.y = speedTextRect.origin.y - 26
            presetsLabel.frame.origin.y = presetsLabelRect.origin.y - shiftDown
            presetDeleteButton.frame.origin.y = presetsLabelRect.origin.y - shiftDown
            
            presetsTableView.superview?.superview!.frame = NSRect(x: (presetsTableView.superview?.superview!.frame.origin.x)!, y: (presetsTableView.superview?.superview!.frame.origin.y)!, width: presetsTableRect.width, height: presetsTableRect.height - shiftDown)
            
            multiGradientSlider.setGradientMode(colorShiftOrBreathing: Breathing, fromKey: fromKey)
        }
    }
    
    private func updateSpeedSliderValue() {
        var trimmed = speedSlider.intValue.description
        trimmed.removeLast(2)
        speedBox.string = trimmed + "s"
    }
    
    public func setMode(mode: String, fromKey: Bool) {
        if (presetsTableRect == nil) {
            presetsTableRect = presetsTableView.superview?.superview!.frame
            presetsLabelRect = presetsLabel.frame
        }
        
        if (mode == "Reactive") {
            showColorShift(show: false, fromKey: false)
            showBreathing(show: false, fromKey: false)
            showReactive(show: true, fromKey: fromKey)
        } else if (mode == "ColorShift") {
            showReactive(show: false, fromKey: false)
            showBreathing(show: false, fromKey: false)
            showColorShift(show: true, fromKey: fromKey)
        } else if (mode == "Breathing") {
            showColorShift(show: false, fromKey: false)
            showReactive(show: false, fromKey: false)
            showBreathing(show: true, fromKey: fromKey)
        } else {
            showReactive(show: false, fromKey: false)
            showColorShift(show: false, fromKey: false)
            showBreathing(show: false, fromKey: false)
            presetsTableView.superview?.superview!.frame = presetsTableRect
            
            presetsLabel.frame.origin.y = presetsLabelRect.origin.y
            presetDeleteButton.frame.origin.y = presetsLabelRect.origin.y - 4
            
        }
        
        updateKeys(shouldUpdateKeys: fromKey ? false : true)
    }
    
    @IBAction func currentMode(_ sender: NSPopUpButtonCell) {
        setMode(mode: sender.titleOfSelectedItem!, fromKey: false)
    }
    
    @IBAction func setSpeed(_ sender: NSSlider) {
        var trimmed = speedSlider.intValue.description
        trimmed.removeLast(2)
        speedBox.string = trimmed + "s"
        let shouldSendKeyCommand = (NSApplication.shared.currentEvent?.type == NSEvent.EventType.leftMouseUp) ? true : false
        updateKeys(shouldUpdateKeys: shouldSendKeyCommand)
    }
        
    @IBAction func setBrightness(_ sender: NSSlider) {
        ColorController.shared.brightness = CGFloat((sender.maxValue-sender.doubleValue) / sender.maxValue)
        updateColorWheel(redrawCrosshair: false)
        updateLabel()
        let shouldSendKeyCommand = (NSApplication.shared.currentEvent?.type == NSEvent.EventType.leftMouseUp) ? true : false
        updateKeys(shouldUpdateKeys: shouldSendKeyCommand)
    }
    
    @IBAction func setColor(_ sender: NSTextField) {
        let color = NSColor(hexString: sender.stringValue)
        ColorController.shared.setColor(color)
        view.window?.makeFirstResponder(view)
        updateKeys(shouldUpdateKeys: true)
    }
    
    @IBAction func setWaveModeClicked(_ sender: NSButton) {
        if (sender.state == .on) {
            updateWaveMode(enable: true)
        } else {
            updateWaveMode(enable: false)
        }
    }
    
    @IBAction func setOriginButtonClicked(_ sender: NSPopUpButtonCell) {
    }
    
    private func updateWaveMode(enable: Bool) {
        setOriginButton.isEnabled = enable
        waveLengthSlider.isEnabled = enable
        waveDirectionPopup.isEnabled = enable
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
    
    func updateKeys(shouldUpdateKeys: Bool) {
        if (KeyboardManager.shared.keyboardManager.getKeyboardModel() != ThreeRegion) {
            if (currentKeyMode.titleOfSelectedItem == "Steady") {
                for key in KeyboardManager.shared.keysSelected {
                    (key as! KeysView).setSteady(newColor: ColorController.shared.selectedColor)
                }
            } else if (currentKeyMode.titleOfSelectedItem == "Reactive") {
                for selected in ColorController.shared.reactionBoxColors {
                    (selected as! CustomColorWell).color = ColorController.shared.selectedColor
                }
                
                for key in KeyboardManager.shared.keysSelected {
                    (key as! KeysView).setReactive(active: activeColor.color, rest: restColor.color, speed: UInt16(speedSlider.intValue))
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
                
                if (shouldUpdateKeys) {
                    let keyEffect = getKeyEffect(isColorShift: true)
                    for key in KeyboardManager.shared.keysSelected {
                        (key as! KeysView).setEffectKey(_id: keyEffect.getEffectId(), mode: ColorShift)
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
                        (key as! KeysView).setEffectKey(_id: keyEffect.getEffectId(), mode: Breathing)
                    }
                }
            } else if (currentKeyMode.titleOfSelectedItem == "Disabled") {
                for key in KeyboardManager.shared.keysSelected {
                    (key as! KeysView).setDisabled()
                }
            }
            /// Removes unused effects
            removeUnusedEffects()
        } else {
            // TODO - Three Region Keyboard
        }
        
        // Will only set color when the mouse is up
        if (shouldUpdateKeys) {
            // Will notify for keyboard GS65 and other PerKey to update the keys once mouse is up
            KeyboardManager.shared.keyboardView.updateKeys()
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
            // keyEffect?.setWaveMode(<#T##origin: KeyPoint##KeyPoint#>, <#T##waveLength: UInt16##UInt16#>, <#T##radControl: WaveRadControl##WaveRadControl#>, <#T##direction: WaveDirection##WaveDirection#>)
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
    
    @IBAction func deletePreset(_ sender: NSButton) {
        if (selectedFile != nil) {
            do {
                let fileManager = FileManager.default
                try fileManager.removeItem(at: selectedFile)
                selectedFile = nil
                checkForPresets()
                self.presetDeleteButton.isEnabled = false
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
        }
    }
}

extension ColorPickerController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (filesList.count)
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let file = filesList[row]
        
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileCell"), owner: self) as? NSTableCellView else { return nil }
        cell.textField?.stringValue = file.deletingPathExtension().lastPathComponent
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if presetsTableView.selectedRow < 0 {
            selectedFile = nil
            presetDeleteButton.isEnabled = false
            return
        }
        presetDeleteButton.isEnabled = true
        selectedFile = filesList[presetsTableView.selectedRow]
    }
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
    func viewDidChange(_ sliderThumb: SliderThumb, mouseUp: Bool) {
        updateKeys(shouldUpdateKeys: mouseUp)
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
