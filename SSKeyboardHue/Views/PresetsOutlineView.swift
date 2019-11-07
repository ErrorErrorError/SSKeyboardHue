//
//  PresetsOutlineView.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 11/6/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class PresetsOutlineView: NSOutlineView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        let point = convert(event.locationInWindow, from: nil)
        let row = self.row(at: point)
        let item = self.item(atRow: row)
        
        guard (item as? PresetItem) != nil else { return nil }
        
        return super.menu(for: event)
    }
    
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let row = self.row(at: point)
        let item = self.item(atRow: row)
        return (item != nil && item as? PresetItem != nil) ? super.mouseDown(with: event) : deselectAll(nil)
    }
}
