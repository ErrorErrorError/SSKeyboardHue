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
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var scrollViewCollections: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        scrollViewCollections.wantsLayer = true
        scrollViewCollections.roundCorners(cornerRadius: 15.0)
        scrollViewCollections.borderType = .noBorder
    }
    
    // Make buttons for keyboard
    func createGS65Keyboard(text:String, y: Int) -> NSColorWell {
        let myButton = KeyboardKeys()
        myButton.frame = NSRect(x:  y*50, y:30, width: 35, height: 35)
        myButton.isBordered = false
        return myButton
    }
    
    override func viewWillAppear() {
        view.layer?.backgroundColor = colorBackground.nsColor.cgColor
        collectionView.layer?.backgroundColor = keyboardBackground.nsColor.cgColor
    }
}
