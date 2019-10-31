//
//  ContentViewController.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/23/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class ContentViewController: NSViewController {
    func sendPresetName(str: String) {
        presetName.stringValue = str
    }
    
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
        
        // let effects = createEffectsPacket()
        var data = Data(bytes: arrayModifiers, count: arrayModifiers.count)
        data.append(arrayAlpha, count: arrayAlpha.count)
        data.append(arrayEnter, count: arrayEnter.count)
        data.append(arraySpecial, count: arraySpecial.count)
        
        if let filePath = filePath(forKey: presetName.stringValue) {
            do {
                try data.write(to: filePath)
            } catch let err {
                print("Failed to save file", err)
            }
        }
        
        ColorController.shared.colorPicker.checkForPresets()
        self.view.window?.performClose(self)
    }
    
    private func createEffectsPacket() -> [UInt8] {
        // let effects = KeyboardManager.shared.effectsArray!
        let arrayPacket: [UInt8] = Array(repeating: 0, count: 0)
        
        /// TODO - Needs implementation
        return arrayPacket
    }
    
    private func createPacket(keysArray: [KeysWrapper]) -> [UInt8] {
        var arrayPacket: [UInt8] = Array(repeating: 0, count: keysArray.count * 12)
                
        for i in 0..<keysArray.count {
            let index = (12 * i);
            let currentKey = keysArray[i]
            var mode: UInt8;
            if (currentKey.getMode() == Steady) {
                mode = 0x01;
            } else if (currentKey.getMode() == Reactive) {
                mode = 0x08;
            } else if (currentKey.getMode() == Disabled){
                mode = 0x03;
            } else {
                mode = 0x0;
            }
                        
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
            arrayPacket[index + 11]   = mode
        }
       
        
        
        return arrayPacket
    }

    
    private func filePath(forKey key: String) -> URL? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let directoryPath = docURL.appendingPathComponent("presets")

        if !FileManager.default.fileExists(atPath: directoryPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: directoryPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
            
        }
        
        let pathData = URL(fileURLWithPath: directoryPath.absoluteString, isDirectory: true)
        

        return pathData.appendingPathComponent(key + ".bin")
    }

}
