//
//  CenterTextFieldCell.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/12/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class CenterTextFieldCell: NSTextFieldCell {
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        let newRect = NSRect(x: 0, y: (rect.size.height - 14) / 2 , width: rect.size.width, height: 14)
        return super.drawingRect(forBounds: newRect)
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let newRect = NSRect(x: 0, y: (rect.size.height - 14) / 2, width: rect.size.width, height: 14)
        super.select(withFrame: newRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        let newRect = NSRect(x: 0, y: (rect.size.height - 14) / 2, width: rect.size.width, height: 14)
        super.edit(withFrame: newRect, in: controlView, editor: textObj, delegate: delegate, event:  event)
    }
}
