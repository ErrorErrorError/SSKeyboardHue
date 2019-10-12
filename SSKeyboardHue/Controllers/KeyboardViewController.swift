//
//  KeyboardViewController.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/1/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class KeyboardViewController: NSViewController {
    
    // var colorBackground = RGB(r: 242, g: 242, b: 250) // Light Mode
    var colorBackground = RGB(r: 14, g: 14, b: 15) // Dark Mode
    var keyboardBackground = RGB(r: 30, g: 30, b: 30) // Dark Mode
    
    @IBOutlet weak var keyboardView: KeyboardView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        keyboardView.roundCorners(cornerRadius: 15.0)
        KeyboardManager.shared.keyboardManager = SSKeyboardWrapper()
        detectKeyboard()
    }
    
    private func detectKeyboard() {
        
        switch KeyboardManager.shared.keyboardManager.getKeyboardModel() {
        case PerKeyGS65:
            createGS65Keyboard()
        case PerKey:
            print("PerKey")
        case ThreeRegion:
            print("ThreeRegion")
        case UnknownModel:
            print("UnknownModel")
        default:
            print("default")
        }
        
        // Sets initial color
        KeyboardManager.shared.keyboardView.sendColorToKeyboard(region: regions.0, createOutput: false)
        KeyboardManager.shared.keyboardView.sendColorToKeyboard(region: regions.1, createOutput: false)
        KeyboardManager.shared.keyboardView.sendColorToKeyboard(region: regions.2, createOutput: false)
        KeyboardManager.shared.keyboardView.sendColorToKeyboard(region: regions.3, createOutput: true)

    }
    
    
    private func createGS65Keyboard() {
        var row = 0
        var key = 0
        var position: Int
        var shiftedPosition: Int
        var width: Int
        var height: Int
        for keys in KeyboardLayoutGS65.keys {
            shiftedPosition = 0
            position = key * 50
            width = 40
            height = 40
            // Shifts position of keys
            if (row == 0) {
                height = 25
                position = key * 51
                width = 42
                
            } else if (row==1) {
                shiftedPosition = -15
                if (keys.value == "~") {
                    width -= 15
                    shiftedPosition = 0
                } else if (keys.value == "BACKSPACE"){
                    width += 30
                } else if (keys.value == "HOME") {
                    shiftedPosition = 15
                }
            } else if (row==2) {
                shiftedPosition = 15
                if (keys.value == "TAB") {
                    width += 15
                    shiftedPosition = 0
                }
            } else if (row==3) {
                shiftedPosition = 25
                if (keys.value == "CAPS LOCK") {
                    width += 25
                    shiftedPosition = 0
                } else if (keys.value == "ENTER") {
                    width += 40
                } else if (keys.value == "PGDN") {
                    shiftedPosition = 65
                }
            } else if (row == 4) {
                // There are two shift keys in this row so we distinguish them based on key
                //Left shift key
                shiftedPosition = 45
                if (keys.key == 0xe0) {
                    width += 45
                    shiftedPosition = 0
                // Right Shift Key
                } else if (keys.key == 0xe4) {
                    width += 20
                } else if (keys.value == "UP" || keys.value == "END") {
                    shiftedPosition = 65
                }
            } else if (row == 5) {
                shiftedPosition = 25
                if (keys.key == 0x65) {
                    width += 25
                    shiftedPosition = 0
                } else if (keys.value == "SPACEBAR") {
                    width += 190
                } else if (key > 3) {
                    shiftedPosition += 190
                }
            }
            
            position += shiftedPosition
            keyboardView.addSubview(createKeys(keys: keys, x: position, row: row, width: width, height: height))
            if (keys.value == "DEL" || keys.value == "HOME" || keys.value == "PGUP" || keys.value == "PGDN" || keys.value == "END") {
                row += 1
                key = 0
            } else {
                key += 1
            }
        }
    }
    
    // Make keys
    private func createKeys(keys: (key:UInt8, value:String), x: Int, row: Int, width: Int, height: Int) -> NSColorWell {
        let rect =  NSRect(x:  50 + x, y: 320 - (row * 50), width: width, height: height)
        let region = getRegionKey(key: keys.key, keyText: keys.value)
        let keyModel = Keys(key: keys.key, keyLetter: keys.value, region: region, color: RGB(r: 0xff, g: 0, b: 0))
        let key = KeyboardKeys(frame: rect, key: keyModel)
        return key
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        keyboardView.resetKeysSelected()
    }
    
    override func viewWillAppear() {
        view.layer?.backgroundColor = colorBackground.nsColor.cgColor
        keyboardView.layer?.backgroundColor = keyboardBackground.nsColor.cgColor
    }
    

    private func getRegionKey(key: UInt8, keyText: String) -> UInt8 {
        if (KeyboardManager.shared.keyboardManager.getKeyboardModel() == PerKeyGS65) {
            //Checks if key is a region key
            if (keyText == "ESC") {
                return regions.0
            } else if (keyText == "A") {
                return regions.1

            } else if (keyText == "ENTER") {
                return regions.2
                
            } else if (keyText == "F7") {
                return regions.3
            }
            
            let regionKey = findKeyInRegion(key)

            return regionKey
        } else if (KeyboardManager.shared.keyboardManager.getKeyboardModel() == PerKey) {
            // TODO - Implement PerKey for other models
        }

        return 0
    }
}
