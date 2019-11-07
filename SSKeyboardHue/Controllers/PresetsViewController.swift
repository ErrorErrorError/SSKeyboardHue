//
//  PresetsViewController.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 11/4/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

protocol PresetsViewControllerDelegate: class {
    func presetWasClicked(presetName: String, shouldHidePreset: Bool)
}

class PresetsViewController: NSViewController {

    @IBOutlet weak var outlineView: PresetsOutlineView!
    private var previousStringBeforeEditing: String!
    
    private var selectedFile: URL! {
        didSet {
            if (self.selectedFile != nil) {
                setKeyboardColorFromFile()
            }
        }
    }
    
    // private var directoryObserver: DirectoryObserver!
    private var directoryWatcher: FileWatcher!
    private var presetsDirectory: URL!
    var delegate: PresetsViewControllerDelegate!
    private let customPresetsIndex: Int = 1
    private let defaultPresetsIndex: Int = 0
    private var presetsArray: [Preset] = [Preset(type: .DefaultPresets),Preset(type: .CustomPresets)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createOrGetPresetsPath()
        setupDefaultPresets()
        checkForCustomPresets()
        
        directoryWatcher = FileWatcher([presetsDirectory])
        
        directoryWatcher.callback = { event in
            self.updateOutlineView(event: event.eventOccuedWithLocation)
        }
        
        directoryWatcher.start()
        
    }
    
    private func setupDefaultPresets() {
        
    }
    
    private func updateOutlineView(event: FileWatcherEvent.EventAndLocation) {
        switch event.eventType {
        case .fileCreated:
            checkForCustomPresets()
        default: break
        }
    }
        
    func checkForCustomPresets() {
        for i in presetsArray {
            if (i.type == .CustomPresets) {
                i.presets = contentsOf().map({ (oldVal) -> PresetItem in
                    return PresetItem(fileName: String(oldVal.lastPathComponent.dropLast(4)), url: oldVal, type: PresetsType.CustomPresets)
                })
                outlineView.reloadData()
            }
        }
    }
    
    // List of presets
    private func contentsOf() -> [URL] {
        let fileManager = FileManager.default
        do {
            var contents = try fileManager.contentsOfDirectory(at: presetsDirectory, includingPropertiesForKeys: .none, options: .skipsHiddenFiles)
            
            try contents.sort {

                let values1 = try $0.resourceValues(forKeys: [.creationDateKey])
                let values2 = try $1.resourceValues(forKeys: [.creationDateKey])

                if let date1 = values1.allValues.first?.value as? Date, let date2 = values2.allValues.first?.value as? Date {

                    return date1.compare(date2) == (.orderedAscending)
                }
                return true
            }
            
            return contents
        } catch {
            return []
        }
    }
    
    // Sets the keys according to the file
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
            
            // Get settings from key array
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
                    let foundColor = KeyboardManager.shared.effectsArray.filter { (effect) -> Bool in
                        let keyEffect = effect as! KeyEffectWrapper
                        if (keyEffect.getEffectId() == effectId) {
                            return true
                        } else {
                            return false
                        }
                    }
                    keyFound.setEffectKey(_id: effectId, mode: mode, color: (foundColor[0] as! KeyEffectWrapper).getStartColor().nsColor)
                } else {
                    keyFound.setDisabled()
                }
            }
            
        } else {
            /// TODO - Implement ThreeRegion
        }
        
        KeyboardManager.shared.keyboardView.updateKeys(forceRefresh: true)
    }
    
    private func createOrGetPresetsPath() {
        let sskeyboardDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("SSKeyboardHue")
        if !FileManager.default.fileExists(atPath: sskeyboardDirectory.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: sskeyboardDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        
        let presetsFolder = sskeyboardDirectory.appendingPathComponent("presets")
        
        if !FileManager.default.fileExists(atPath: presetsFolder.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: presetsFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
                
        presetsDirectory = presetsFolder
    }
    
    private func usedString(string: String) -> Bool {
        var isUsed = false
        for i in presetsArray[customPresetsIndex].presets {
            isUsed = i.name == string
            if (isUsed) {
                break
            }
        }
        return isUsed
    }
    
    private func updatePresetWithNewName(string: String) {
        
        guard previousStringBeforeEditing != nil else {return}
        
        let item = presetsArray[customPresetsIndex].presets.filter { (someItem) -> Bool in
            return someItem.name == previousStringBeforeEditing
        }.first!
        
        let newUrl = presetsDirectory.appendingPathComponent(string + ".bin")
        item.name = string
        
        do {
            try FileManager.default.moveItem(at: item.urlLocation, to: newUrl)
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
        checkForCustomPresets()
    }
    
    @IBAction func clickedRename(_ sender: NSMenuItem) {
        let row = outlineView.clickedRow
        guard let rowView = outlineView.rowView(atRow: row, makeIfNecessary: false) else { return }

        guard let cell = rowView.view(atColumn: 0) as? NSTableCellView else { return }
        cell.textField?.isEditable = true
        self.outlineView.window?.makeFirstResponder(cell.textField)
    }
    
    /// Deletes the custom preset. You can only delete the custom preset and not the default preset
    @IBAction func clickedDelete(_ sender: Any) {
        guard let item = outlineView.item(atRow: outlineView.clickedRow) as? PresetItem else { return }
        let parentItem = outlineView.parent(forItem: item) as! Preset
        let actuaIndexInOutline = outlineView.clickedRow - (presetsArray[defaultPresetsIndex].presets.count + presetsArray.count)
        let indexSet = NSIndexSet(index: actuaIndexInOutline)
        outlineView.removeItems(at: indexSet as IndexSet, inParent: parentItem, withAnimation: .effectFade)
        do {
            try FileManager.default.removeItem(at: item.urlLocation)
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
    }
}

extension PresetsViewController: NSTextDelegate, NSControlTextEditingDelegate {
    func controlTextDidBeginEditing(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            previousStringBeforeEditing = textField.stringValue
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        guard (previousStringBeforeEditing != nil) else { return }
        guard let textField = obj.object as? NSTextField else { return }
        textField.isEditable = false
        let stringValidation = textField.stringValue.trimmingCharacters(in: .whitespaces)
        if (stringValidation.isEmpty || usedString(string: stringValidation)) {
            textField.stringValue = previousStringBeforeEditing
        } else if (textField.stringValue != previousStringBeforeEditing) {
            updatePresetWithNewName(string: stringValidation)
        }
        
        previousStringBeforeEditing = nil
    }
}

extension PresetsViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? Preset {
            return item.presets.count
        } else {
            return presetsArray.count
        }
    }
        
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? Preset {
            return item.presets[index]
        } else {
            return presetsArray[index]
        }
        
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if (item is Preset) {
            return true
        }
        
        return false
    }
    
}

extension PresetsViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let item = item as? PresetItem {
            guard let dataCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView else { return nil }
            dataCell.textField?.stringValue = item.name
            return dataCell
        } else if let item = item as? Preset {
            guard let dataCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as? NSTableCellView else { return nil }
            dataCell.textField?.stringValue = item.type.rawValue
            return dataCell
        }
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        if item is Preset {
            return true
        }
        return false
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if outlineView.selectedRow < 0 {
            selectedFile = nil
            delegate.presetWasClicked(presetName: "", shouldHidePreset: false)
            return
        }
        
        if let item = outlineView.item(atRow: outlineView.selectedRow) as? PresetItem {
            selectedFile = item.urlLocation
            delegate.presetWasClicked(presetName: item.name, shouldHidePreset: false)
        } else {
            selectedFile = nil
            delegate.presetWasClicked(presetName: "", shouldHidePreset: false)
        }
    }
}
 
class Preset : NSObject {
    let type: PresetsType
    var presets = [PresetItem]()
    init (type: PresetsType){
        self.type = type
    }
}

class PresetItem: NSObject {
    var name: String
    var urlLocation: URL
    let presetType: PresetsType
    
    init (fileName: String, url: URL, type: PresetsType) {
        self.name = fileName
        self.urlLocation = url
        self.presetType = type
    }
}

enum PresetsType: String, CaseIterable {
    case DefaultPresets = "Default Presets"
    case CustomPresets = "Custom Presets"
}
