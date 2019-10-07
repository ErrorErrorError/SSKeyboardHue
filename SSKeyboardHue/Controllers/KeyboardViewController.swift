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
    
    @IBOutlet weak var keyboardView: NSView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        keyboardView.wantsLayer = true
        keyboardView.roundCorners(cornerRadius: 15.0)
        createGS65Keyboard()
    }
    
    
    private func createGS65Keyboard() {
        var row = 0
        var key = 0
        var hasSetFNKeys = false
        for keys in KeyboardLayoutGS65.keys {
            if (!hasSetFNKeys) {
                keyboardView.addSubview(createKeys(text: keys.value, x: key, row: row, width: 40, height: 25))
                if (keys.value == "DEL") {
                    hasSetFNKeys = true
                }
            } else {
                keyboardView.addSubview(createKeys(text: keys.value, x: key, row: row, width: 40, height: 40))
            }

            if (keys.value == "DEL" || keys.value == "HOME" || keys.value == "PGUP" || keys.value == "PGDN" || keys.value == "END") {
                row += 1
                key = 0
            } else {
                key += 1
            }
        }
    }
    
    // Make GS65 keyboard
    private func createKeys(text:String, x: Int, row: Int, width: Int, height: Int) -> NSColorWell {
        let key = KeyboardKeys(frame: NSRect(x:  55 + 50*x, y: 320 - (row * 50), width: width, height: height),keyLetter: text,newColor: RGB(r: 0xff, g: 0, b: 0))
        return key
    }
    
    override func viewWillAppear() {
        view.layer?.backgroundColor = colorBackground.nsColor.cgColor
        keyboardView.layer?.backgroundColor = keyboardBackground.nsColor.cgColor
    }
}
