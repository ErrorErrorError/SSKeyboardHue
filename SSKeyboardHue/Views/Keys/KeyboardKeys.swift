//
//  SSKeyboardKeys.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/3/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class KeyboardKeys: NSColorWell {
    var isSelected = false;
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        /*
        ColorController.shared.setColor(color.usingColorSpace(NSColorSpace.genericRGB)!)
        if (!isSelected) {
            isSelected = true
        } else {
            isSelected = false
        }
        print(isSelected)
 */
    }
    /*
    override func mouseDown(with event: NSEvent) {
        let pasteboardItem = NSPasteboardItem()
        //pasteboardItem.setDataProvider(self, forTypes: [.color])
        let draggingImage = NSImage(size: bounds.size)
        draggingImage.lockFocus()
        self.color.drawSwatch(in: bounds)
        draggingImage.unlockFocus()
        let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
        draggingItem.setDraggingFrame(bounds, contents: draggingImage)
        //beginDraggingSession(with: [draggingItem], event: event, source: self)
    }
 */
}

/*
extension SSKeyboardKeys: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession,
                         sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation
    {
        return .generic
    }
}

extension SSKeyboardKeys: NSPasteboardItemDataProvider {
    func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem,
                    provideDataForType type: NSPasteboard.PasteboardType)
    {
        guard let pasteboard = pasteboard, type == .color else { return }
        ColorController.shared.selectedColor.write(to: pasteboard)
    }
}
*/
