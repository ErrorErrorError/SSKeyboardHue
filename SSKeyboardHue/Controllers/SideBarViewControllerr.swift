//
//  SSSideBarViewController.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/2/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class SideBarViewController: NSViewController {

    // public static var colorBackground = RGB(r: 234, g: 237, b: 247) // Light Mode
    var colorBackground = RGB(r: 17, g: 17, b: 18) // Dark mode

    @IBOutlet var box: NSView!
    @IBOutlet weak var containerColorPicker: NSView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
    }

    override func viewWillAppear() {
        box.layer?.backgroundColor = colorBackground.nsColor.cgColor
    }
}
