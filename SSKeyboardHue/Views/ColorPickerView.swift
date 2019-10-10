//
//  ColorPickerView.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/4/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

/// `ColorPickerViewController` content view. Allows colors to be dragged in.
@IBDesignable
class ColorPickerView: NSView {
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        registerForDraggedTypes([.color])
    }
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.color])
    }
    override func awakeFromNib() {
        registerForDraggedTypes([.color])
    }
    
    // MARK: - NSDraggingDestination
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        guard let colors = pasteboard.readObjects(forClasses: [NSColor.self], options: nil) as? [NSColor],
            colors.count > 0
            else { return false }
        // Cancel if dragged color is the same as the current color
        //let allowed = ColorController.shared.selectedColor != colors[0]
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        guard let colors = pasteboard.readObjects(forClasses: [NSColor.self], options: nil) as? [NSColor],
            colors.count > 0
            else { return false }
        ColorController.shared.setColor(colors[0].usingColorSpace(NSColorSpace.genericRGB)!)
        return true
    }
    
    // Allows mouse click to lose `ColorPickerViewController`'s text field's focus
    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
    }
}
