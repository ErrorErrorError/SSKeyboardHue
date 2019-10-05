//
//  CustomSplitView.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/2/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class CustomSplitView: NSSplitView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    // Removes divider
    override var dividerThickness:CGFloat {
        get { return 0.0 }
    }

}
