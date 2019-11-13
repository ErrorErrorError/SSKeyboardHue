//
//  ColorPickerView.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/3/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//
// Color Picker is from here https://github.com/Gofake1/Color-Picker/blob/master/Color%20Picker/ColorWheelView.swift

import Cocoa

protocol ColorWheelViewDelegate: class {
    func colorDidChange(_ newColor: NSColor, shouldUpdateKeyboard: Bool)
}

@IBDesignable
class ColorWheelView: NSView {
    weak var delegate: ColorWheelViewDelegate?
    private var colorWheelImage: CGImage!
    private var blackImage: NSBezierPath!
    private var brightness: CGFloat = 1.0
    private var pickerLocation: CGPoint!
    private(set) var selectedColor = NSColor(red: 0xff, green: 0xff, blue: 0xff, alpha: 1.0)
    private var mouseUp = false
    private var isClampedOutside = false
    var isEnabled = true {
        didSet {
            needsDisplay = true
        }
    }
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    func setup() {
        blackImage      = createBlackImage()
        colorWheelImage = createColorWheelImage()
        pickerLocation  = point(for: selectedColor, center: CGPoint(x: frame.width/2, y: frame.height/2))
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        /// Draw ColotWheel
        context.draw(colorWheelImage, in: dirtyRect)
        context.setAlpha(1.0)
        
        /// Draw black filter
        if (isEnabled) {
            NSColor.black.withAlphaComponent(1.0 - brightness).setFill()
        } else {
            NSColor.black.withAlphaComponent(0.5).setFill()
        }
        blackImage.fill()

        /// Draw Crosshair
        if brightness < 0.5 {
            context.setStrokeColor(CGColor.white)
        } else {
            context.setStrokeColor(CGColor.white)
        }
        
        context.addEllipse(in: CGRect(origin: CGPoint(x: pickerLocation.x-5.5, y: pickerLocation.y-5.5),
                                      size: CGSize(width: 11, height: 11)))
        context.setLineWidth(2.0)
        context.strokePath()
    }
    
    func setColor(_ newColor: NSColor, _ redrawCrosshair: Bool = true) {
        if redrawCrosshair {
            let center = CGPoint(x: frame.width/2, y: frame.height/2)
            pickerLocation = point(for: newColor, center: center) ?? center
        }
        selectedColor = newColor
        brightness = newColor.scaledBrightness
        needsDisplay = true
    }
    
    private func createColorWheelImage() -> CGImage {
        let filter = CIFilter(name: "CIHueSaturationValueGradient", parameters: [
            "inputColorSpace": CGColorSpaceCreateDeviceRGB(),
            "inputDither": 0,
            "inputRadius": bounds.width,
            "inputSoftness": 0,
            "inputValue": 1
        ])!
        
        let ciimage = filter.outputImage!.oriented(.rightMirrored)
        return convertCIImageToCGImage(inputImage: ciimage)!
    }
    
    private func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
    
    private func createBlackImage() -> NSBezierPath {
        return NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: frame.width, height: frame.height))
    }
        
    private func point(for color: NSColor, center: CGPoint) -> CGPoint? {
        let h = color.hueComponent
        let s = color.saturationComponent
        let angle = h * 2 * CGFloat.pi
        let distance = s * center.x
        let x = center.x + sin(angle)*distance
        let y = center.y + cos(angle)*distance
        return CGPoint(x: x, y: y)
    }
    
    /// - returns: Clamped point and boolean indicating if the point was clamped
    private func clamped(_ point: CGPoint) -> (CGPoint, Bool) {
        let centerX = frame.width/2
        let centerY = frame.height/2
        let vX = point.x - centerX
        let vY = point.y - centerY
        let distanceFromCenter = sqrt((vX*vX) + (vY*vY))
        let radius = frame.width/2
        if distanceFromCenter > radius {
            return (CGPoint(x: centerX + vX/distanceFromCenter * radius,
                            y: centerY + vY/distanceFromCenter * radius), true)
        } else {
            return (point, false)
        }
    }
    
    /// - postcondition: Calls `delegate`
    private func setColor(at point: CGPoint) {
        selectedColor = NSColor(coord: (Int(point.x), Int(point.y)),
                                center: (Int(frame.width/2), Int(frame.height/2)),
                                brightness: 1.0)
        delegate?.colorDidChange(selectedColor, shouldUpdateKeyboard: mouseUp)
    }
    
    // MARK: - Mouse
    /// - postcondition: May call `NSWindow.makeFirstResponder`
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if (isEnabled) {
            mouseUp = false

            let (clampedPoint, wasClamped) = clamped(convert(event.locationInWindow, from: nil))
            
            if wasClamped {
                window?.makeFirstResponder(window?.contentView)
                isClampedOutside = wasClamped
            } else {
                isClampedOutside = false
                pickerLocation = clampedPoint
                needsDisplay = true
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        if (isEnabled) {
            mouseUp = false
            if (!isClampedOutside) {
                let (clampedPoint, _) = clamped(convert(event.locationInWindow, from: nil))
                setColor(at: clampedPoint)
                pickerLocation = clampedPoint
                needsDisplay = true
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        if (isEnabled) {
            mouseUp = true
            if (!isClampedOutside) {
                let (clampedPoint, _) = clamped(convert(event.locationInWindow, from: nil))
                setColor(at: clampedPoint)
            }
        }
    }
}
