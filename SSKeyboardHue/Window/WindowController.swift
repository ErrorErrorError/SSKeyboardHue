//
//  WindowControllwe.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 9/30/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        let customToolbar = NSToolbar()
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
        customToolbar.showsBaselineSeparator = false
        window?.toolbar = customToolbar
        window?.styleMask.insert(.fullSizeContentView)
    }
    
    override func keyDown(with event: NSEvent) {
        return;
    }
}
