//
//  CustomSplitViewController.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/2/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class CustomSplitViewController: NSSplitViewController {
    
    @IBOutlet weak var leftItem: NSSplitViewItem!
    @IBOutlet weak var rightItem: NSSplitViewItem!
    override func viewDidLoad() {

        super.viewDidLoad()
    }
    
    // Removes divider interaction
    open override func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        return NSZeroRect
    }
}

