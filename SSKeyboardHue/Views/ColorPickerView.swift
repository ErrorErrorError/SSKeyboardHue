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
    /*
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        registerForDraggedTypes([.keysShift])
    }
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.keysShift])
    }
    override func awakeFromNib() {
        registerForDraggedTypes([.keysShift])
    }
    
    // MARK: - NSDraggingDestination
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        guard let key = pasteboard.readObjects(forClasses: [KeysWrapper.self], options: nil) as? [KeysWrapper],
            key.count > 0
            else { return false }
        // Cancel if dragged color is the same as the current color
        //let allowed = ColorController.shared.selectedColor != colors[0]
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        guard let keys = pasteboard.readObjects(forClasses: [KeysWrapper.self], options: nil) as? [KeysWrapper],
            keys.count > 0
            else { return false }
        ColorController.shared.setKey(key: keys[0])
        return true
    }
 
 */
    // Allows mouse click to lose `ColorPickerViewController`'s text field's focus
    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        
        if (ColorController.shared.reactionModeSelected!.count > 0) {
            for i in ColorController.shared.reactionModeSelected! {
                (i as! CustomColorWell).removeSelected()
            }
        }
    }
}
