//
//  CustomSplitViewController.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/2/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

class CustomSplitViewController: NSSplitViewController {
    
    @IBOutlet weak var presetsVCItem: NSSplitViewItem!
    @IBOutlet weak var colorPickerVCItem: NSSplitViewItem!
    @IBOutlet weak var keyboardVCItem: NSSplitViewItem!
    var presetsVC: PresetsViewController!
    var colorPickerVC: ColorPickerController!
    var keyboardVC: KeyboardViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presetsVC = presetsVCItem.viewController as? PresetsViewController
        colorPickerVC = colorPickerVCItem.viewController as? ColorPickerController
        keyboardVC = keyboardVCItem.viewController as? KeyboardViewController

        presetsVC.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(shouldShowPresets(notfication:)), name: .shouldShowPresets, object: nil)
    }
    
    // Removes divider interaction
    open override func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        return NSZeroRect
    }
    
    private func shouldShowPresets() {
        if (presetsVCItem.isCollapsed) {
            presetsVCItem.animator().isCollapsed = false
        } else {
            presetsVCItem.animator().isCollapsed = true
        }
    }
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        let currentPoint = event.locationInWindow
        if (!presetsVCItem.isCollapsed && !NSPointInRect(currentPoint, presetsVC.view.frame)) {
            shouldShowPresets()
        }
    }
    
    @objc func shouldShowPresets(notfication: NSNotification) {
         shouldShowPresets()
    }
}

extension CustomSplitViewController: PresetsViewControllerDelegate {
    func presetWasClicked(presetName: String, shouldHidePreset: Bool) {
        if (shouldHidePreset) {
            shouldShowPresets()
        }
        
        keyboardVC.stringFile = presetName
    }
}
