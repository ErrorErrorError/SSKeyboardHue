//
//  ContentViewController.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/23/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class ContentViewController: NSViewController {
    @IBOutlet weak var presetName: NSTextField!
    @IBOutlet weak var savePresetButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func clickedSave(_ sender: NSButton) {
        let keysModifiers = KeyboardManager.shared.keyboardView.getKeysArray(region: regions.0)
        let arrayModifiers = createPacket(keysArray: keysModifiers)
        let keysAlpha = KeyboardManager.shared.keyboardView.getKeysArray(region: regions.1)
        let arrayAlpha = createPacket(keysArray: keysAlpha)
        let keysEnter = KeyboardManager.shared.keyboardView.getKeysArray(region: regions.2)
        let arrayEnter = createPacket(keysArray: keysEnter)
        let keysSpecial = KeyboardManager.shared.keyboardView.getKeysArray(region: regions.3)
        let arraySpecial = createPacket(keysArray: keysSpecial)
        
        let effects = createEffectsPacket()
        
        var data = Data(bytes: arrayModifiers, count: arrayModifiers.count)
        data.append(arrayAlpha, count: arrayAlpha.count)
        data.append(arrayEnter, count: arrayEnter.count)
        data.append(arraySpecial, count: arraySpecial.count)
        data.append(effects, count: effects.count)
        
        if let filePath = filePath(forKey: presetName.stringValue) {
            do {
                try data.write(to: filePath)
            } catch let err {
                print("Failed to save file", err)
            }
        }
        
        self.view.window?.performClose(self)
    }
    
    private func createEffectsPacket() -> [UInt8] {
        let effects = KeyboardManager.shared.effectsArray
        var arrayPacket: [UInt8] = []
        for i in effects {
            let effect = i as! KeyEffectWrapper
            arrayPacket.append(effect.getEffectId())
            arrayPacket.append(effect.getTransitionSize())
            for i in 0..<effect.getTransitionSize() {
                let transition: KeyTransition = effect.getTransitions()[Int(i)]
                arrayPacket.append(transition.color.r)
                arrayPacket.append(transition.color.g)
                arrayPacket.append(transition.color.b)
                arrayPacket.append(UInt8(transition.duration & 0x00ff))
                arrayPacket.append(UInt8((transition.duration & 0xff00) >> 8))
            }
            arrayPacket.append(UInt8(effect.getWaveDirection().rawValue))
            
            arrayPacket.append(UInt8(effect.getWaveLength() & 0x00ff))
            arrayPacket.append(UInt8((effect.getWaveLength() & 0xff00) >> 8))
            
            arrayPacket.append(UInt8(effect.getWaveOrigin().x & 0x00ff))
            arrayPacket.append(UInt8((effect.getWaveOrigin().x & 0xff00) >> 8))
            arrayPacket.append(UInt8(effect.getWaveOrigin().y & 0x00ff))
            arrayPacket.append(UInt8((effect.getWaveOrigin().y & 0xff00) >> 8))
            
            arrayPacket.append(UInt8(effect.getWaveRadControl().rawValue))
            
            arrayPacket.append(effect.isWaveModeActive() ? 1 : 0)
        }
        /// TODO - Needs implementation
        return arrayPacket
    }
    
    private func createPacket(keysArray: [KeysWrapper]) -> [UInt8] {
        var arrayPacket: [UInt8] = Array(repeating: 0, count: keysArray.count * 12)
                
        for i in 0..<keysArray.count {
            let index = (12 * i);
            let currentKey = keysArray[i]
                        
            // The first key should be the the region key.
            arrayPacket[index]    = currentKey.getRegion()
            arrayPacket[index+1]  = currentKey.getKeyCode()
            
            arrayPacket[index + 2]    = currentKey.getMainColor().r
            arrayPacket[index + 3]    = currentKey.getMainColor().g
            arrayPacket[index + 4]    = currentKey.getMainColor().b
            arrayPacket[index + 5]    = currentKey.getActiveColor().r
            arrayPacket[index + 6]    = currentKey.getActiveColor().g
            arrayPacket[index + 7]    = currentKey.getActiveColor().b
            // Splits the UInt16 into two uint8_t
            arrayPacket[index + 8]    = UInt8(currentKey.getSpeed() & 0x00ff)
            arrayPacket[index + 9]    = UInt8((currentKey.getSpeed() & 0xff00) >> 8)
            arrayPacket[index + 10]   = currentKey.getEffectId()
            arrayPacket[index + 11]   = UInt8(currentKey.getMode().rawValue)
        }
        
        return arrayPacket
    }

    
    private func filePath(forKey key: String) -> URL? {
        guard let sskeyboardDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("SSKeyboardHue") else { return nil }
        let presetsFolder = sskeyboardDirectory.appendingPathComponent("presets")
        let newPreset = presetsFolder.appendingPathComponent(key + ".bin")
        return newPreset
    }
}
