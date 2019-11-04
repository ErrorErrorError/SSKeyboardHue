//
//  KeyboardViewController.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/1/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class KeyboardViewController: NSViewController, NSPopoverDelegate {
    
    // var colorBackground = RGB(r: 242, g: 242, b: 250) // Light Mode
    var colorBackground = RGB(r: 14, g: 14, b: 15) // Dark Mode
    var keyboardBackground = RGB(r: 30, g: 30, b: 30) // Dark Mode
    @IBOutlet weak var keyboardView: KeyboardView!
    @IBOutlet weak var optionsButton: NSButton!
    @IBOutlet weak var gradientOriginView: NSView!
    
    lazy var optionsPopOver: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = ContentViewController()
        popover.delegate = self
        popover.animates = true
        return popover
    }()
    
    
    override func viewWillAppear() {
        view.layer?.backgroundColor = colorBackground.nsColor.cgColor
        keyboardView.layer?.backgroundColor = keyboardBackground.nsColor.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        ColorController.shared.colorPicker.delegate = self
        keyboardView.roundCorners(cornerRadius: 15.0)
        KeyboardManager.shared.keyboardManager = SSKeyboardWrapper()
        detectKeyboard()

        setupGradientOriginPicker()
    }
    
    private func setupGradientOriginPicker() {
        gradientOriginView.frame = keyboardView.frame
        gradientOriginView.isHidden = true
    }

    
    private func detectKeyboard() {
        
        switch KeyboardManager.shared.keyboardManager.getKeyboardModel() {
        case PerKeyGS65:
            createGS65Keyboard()
            createNullKeys(isGS65: true)
        case PerKey:
            keyboardView.frame = NSRect(x: keyboardView.frame.origin.x - 40, y: keyboardView.frame.origin.y, width: keyboardView.frame.width + 100, height: keyboardView.frame.height - 40)
            createPerKeyKeyboard()
            createNullKeys(isGS65: false)
        case ThreeRegion:
            print("ThreeRegion")
        case UnknownModel:
            print("UnknownModel")
        default:
            print("default")
        }
        
        // Sets initial color
        // KeyboardManager.shared.keyboardView.sendColorToKeyboard(region: regions.0, createOutput: false)
        // KeyboardManager.shared.keyboardView.sendColorToKeyboard(region: regions.1, createOutput: false)
        // KeyboardManager.shared.keyboardView.sendColorToKeyboard(region: regions.2, createOutput: false)
        // KeyboardManager.shared.keyboardView.sendColorToKeyboard(region: regions.3, createOutput: true)
    }
    
    private func createNullKeys(isGS65: Bool) {
        let nullKeys: KeyValuePairs<UInt8, String>!
        if (isGS65) {
            nullKeys = KeyboardLayout.nullGS65Keys
        } else {
            nullKeys = KeyboardLayout.nullPerKey
        }
        for keys in nullKeys {
            let region = getRegionKey(key: keys)
            let keyModel = KeysWrapper(steady: keys.key, keys.value.getUnsafeMutablePointer(), region, RGB(r: 0x00, g: 0x00, b: 0x00))!
            let key = KeysView(frame: NSRect(x: 0, y: 0, width: 0, height: 0), key: keyModel)
            key.isHidden = true;
            keyboardView.addSubview(key)
        }
    }
    
    private func createPerKeyKeyboard() {
        var row = 0
        var key = 0
        var hPosition: Int
        var shiftedPosition: Int
        var width: Int
        var height: Int
        for keys in KeyboardLayout.keysPerKey {
            shiftedPosition = 0
            hPosition = 20 + (key * 46)
            width = 40
            height = 40
            // Shifts hPosition of keys
            if (row == 0) {
                height = 28
                width = 38
                if (key > 15) {
                    shiftedPosition = -24
                } else {
                    hPosition = 20 + (key * 44)
                }
            } else if (row == 1) {
                shiftedPosition = 20
                if (keys.value == "~") {
                    width += shiftedPosition
                    shiftedPosition = 0
                } else if (keys.value == "BACKSPACE") {
                    width += 40
                } else if (key > 13) {
                    shiftedPosition += 48
                    //width = 32
                }
            } else if (row == 2) {
                shiftedPosition = 30
                if (keys.value == "TAB") {
                    width += shiftedPosition
                    shiftedPosition = 0
                }
                
                if (keys.value == "\\") {
                    width += 30
                } else if (key > 13) {
                    shiftedPosition += 38
                }
                
            } else if (row == 3) {
                shiftedPosition = 40
                if (keys.value == "CAPS LOCK") {
                    width += shiftedPosition
                    shiftedPosition = 0
                }
                
                if (keys.value == "ENTER") {
                    width += 66
                } else if (key > 12) {
                    shiftedPosition += 74
                }
                
                if (keys.value == "+") {
                    height += 46
                }
            } else if (row == 4) {
                shiftedPosition = 66
                if (keys.key == 0xe0) {
                    width += shiftedPosition
                    shiftedPosition = 0
                }
                
                if (keys.key == 0xe4) {
                    width += 40
                }
                
                if (keys.value == "UP") {
                    shiftedPosition += 40
                } else if (key > 12) {
                    shiftedPosition += 48
                }
            } else {
                shiftedPosition = 42
                if (keys.key == 0x65) {
                    width += shiftedPosition
                    shiftedPosition = 0
                }
                
                if (keys.value == "SPACEBAR") {
                    width += 202
                } else if (key > 3) {
                    shiftedPosition += 202
                }
                
                if (key > 10) {
                    shiftedPosition += 8
                }
                
                if (keys.value == "ENTER ") {
                    height += 46
                }
                
            }
            
            hPosition += shiftedPosition
            let vertical = 250 - (row * 46)
            let keyView = createKeys(keys: keys, x: hPosition,y: vertical, row: row, width: width, height: height)
            keyView.textSize = 10.0
            keyboardView.addSubview(keyView)
            if (keys.value == "PGDN" || keys.key == 0x55 || keys.key == 0x60 || keys.key == 0x56 || keys.key == 0x57 || keys.key == 0x5a) {
                row += 1
                key = 0
            } else {
                key += 1
            }
        }
    }
    
    private func createGS65Keyboard() {
        var row = 0
        var key = 0
        var hPosition: Int
        var shiftedPosition: Int
        var width: Int
        var height: Int
        for keys in KeyboardLayout.keysGS65 {
            shiftedPosition = 0
            hPosition = 35 + (key * 50)
            width = 40
            height = 40
            // Shifts hPosition of keys
            if (row == 0) {
                height = 25
                hPosition = 35 + key * 51
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
                // Left Control
                if (keys.key == 0x65) {
                    width += 25
                    shiftedPosition = 0
                } else if (keys.value == "SPACEBAR") {
                    width += 190
                } else if (key > 3) {
                    shiftedPosition += 190
                }
            }
            
            hPosition += shiftedPosition
            let vertical = 290 - (row * 50)
            let keyView = createKeys(keys: keys, x: hPosition, y: vertical, row: row, width: width, height: height)
            keyboardView.addSubview(keyView)
            if (keys.value == "DEL" || keys.value == "HOME" || keys.value == "PGUP" || keys.value == "PGDN" || keys.value == "END") {
                row += 1
                key = 0
            } else {
                key += 1
            }
        }
    }
    
    @IBAction func optionClicked(_ sender: NSButton) {
        if (optionsPopOver.isShown) {
            optionsPopOver.close()
            return
        } else {
            let entryRect = sender.convert(sender.bounds, to: self.view.window?.contentView)
            optionsPopOver.show(relativeTo: entryRect, of: self.view.window!.contentView!, preferredEdge: .maxY)
        }
        
        // Sets text to textbox if a file is selected
        let vc = optionsPopOver.contentViewController as! ContentViewController
        let currentFile = ColorController.shared.colorPicker.selectedFile
        var stringToSend = ""
        if (currentFile != nil) {
            stringToSend = currentFile!.lastPathComponent
            stringToSend.removeLast(4)
        }
        vc.presetName.stringValue = stringToSend
        
    }
    
    // Make keys
    private func createKeys(keys: (key:UInt8, value:String), x: Int,y: Int, row: Int, width: Int, height: Int) -> KeysView {
        let region = getRegionKey(key: keys)
        let rect =  NSRect(x:  x, y: y, width: width, height: height)
        let keyModel = KeysWrapper(steady: keys.key, keys.value.getUnsafeMutablePointer(), region, RGB(r: 0xff, g: 0x00, b: 0x00))!
        let key = KeysView(frame: rect, key: keyModel)
        return key
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        keyboardView.resetKeysSelected()
    }
    
    private func shoudShowOriginView() {
        if (gradientOriginView.isHidden) {
            gradientOriginView.isHidden = false
        } else {
            gradientOriginView.isHidden = true
        }
    }
    
    private func getRegionKey(key: (key:UInt8, value:String)) -> UInt8 {
        let keyboardManager = KeyboardManager.shared.keyboardManager!
        if (keyboardManager.getKeyboardModel() != ThreeRegion) {
            
            if (key.value == "ESC") {
                return regions.0
            } else if (key.value == "A") {
                return regions.1
                
            } else if (key.value == "ENTER") {
                return regions.2
                
            } else if (key.value == "F7") {
                return regions.3
            }
            let regionKey = keyboardManager.findRegion(ofKey: key.key)
            return regionKey
        }
        
        return 0
    }
    
    // From https://gist.github.com/yossan/51019a1af9514831f50bb196b7180107
    private func makeCString(from str: String) -> UnsafeMutablePointer<Int8> {
        let count = str.utf8.count + 1
        let result = UnsafeMutablePointer<Int8>.allocate(capacity: count)
        str.withCString { (baseAddress) in
            // func initialize(from: UnsafePointer<Pointee>, count: Int)
            result.initialize(from: baseAddress, count: count)
        }
        return result
    }
}

extension KeyboardViewController: OriginButtonClickedDelegate {
    func buttonHasClicked(_ button: NSButton) {
        shoudShowOriginView()
    }
}

extension String {
    func getUnsafeMutablePointer() -> UnsafeMutablePointer<Int8> {
        let count = self.utf8.count + 1
        let result = UnsafeMutablePointer<Int8>.allocate(capacity: count)
        self.withCString { (baseAddress) in
            // func initialize(from: UnsafePointer<Pointee>, count: Int)
            result.initialize(from: baseAddress, count: count)
        }
        return result
    }
}
