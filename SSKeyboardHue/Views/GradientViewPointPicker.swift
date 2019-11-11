//
//  GradientViewPointPicker.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 11/3/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

protocol GradientViewPointPickerDelegate: class {
    func newValueUpdated(calcVal: KeyPoint)
}

class GradientViewPointPicker: NSView {
    private var crosshairLocation: NSPoint!
    private var crosshairSize: NSSize!
    private var didPointToCrosshair = false
    private var startPoint: NSPoint!
    weak var delegate : GradientViewPointPickerDelegate?
    var typeOfRad: WaveRadControl! {
        didSet {
            needsDisplay = true
        }
    }
    
    var colorArray: [NSColor] = [NSColor.red, NSColor.blue, NSColor.black] {
        didSet {
            needsDisplay = true
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        ColorController.shared.gradientViewPoint = self
        crosshairLocation = NSPoint(x: frame.width/2, y: frame.height/2)
        crosshairSize = NSSize(width: 20, height: 20)
        typeOfRad = XY
    }
    
    override func mouseDown(with event: NSEvent) {
        let currentPoint = convert(event.locationInWindow, from: nil)
        let modifiedPoint = NSPoint(x:currentPoint.x + crosshairSize.width/2, y: currentPoint.y + crosshairSize.height/2)
        let crosshairRect = NSRect(origin: crosshairLocation, size: crosshairSize)
        didPointToCrosshair = NSPointInRect(modifiedPoint, crosshairRect)
        startPoint = calcBounds(point: currentPoint)
    }
    
    override func mouseDragged(with event: NSEvent) {
        let currentPoint = convert(event.locationInWindow, from: nil)
        if (didPointToCrosshair) {
            crosshairLocation = calcBounds(point: currentPoint)
            needsDisplay = true
        }
    }
    
    private func calcBounds(point: NSPoint) -> NSPoint {
        var newPoint = NSPoint()
        if (frame.width >= point.x && point.x >= 0) {
            newPoint.x = point.x
        } else if (point.x < 0) {
            newPoint.x = 0
        } else if (point.x > frame.width) {
            newPoint.x = frame.width
        }
        
        if (frame.height >= point.y && point.y >= 0) {
            newPoint.y = point.y
        } else if (point.y < 0) {
            newPoint.y = 0
        } else if (point.y > frame.height) {
            newPoint.y = frame.height
        }

        return newPoint
    }
    
    override func mouseUp(with event: NSEvent) {
        let currentPoint = convert(event.locationInWindow, from: nil)
        if (startPoint != nil) {
            if (startPoint != currentPoint) {
                let getCalcVal = getCalculatedOrigin()
                delegate?.newValueUpdated(calcVal: getCalcVal)
            }
            
            startPoint = nil
        }
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        var newColorArray: [NSColor] = []
        var newLocation: [CGFloat] = []
                
        if (typeOfRad == XY) {
            for i in 0..<colorArray.count {
                let index = i
                let color = colorArray[index]
                var location: CGFloat
                location = CGFloat(i + 1) / CGFloat(colorArray.count)
                newColorArray.append(color.withAlphaComponent(0.70))
                newLocation.append(location)
            }
            guard let bgGradient = NSGradient(colors: newColorArray, atLocations: newLocation, colorSpace: .genericRGB) else { return }
            let newPointX = KeysView.map(x: crosshairLocation!.x, in_min: 0, in_max: frame.width, out_min: -1.0, out_max: 1.0) - 1
            let newPointY = KeysView.map(x: crosshairLocation!.y, in_min: 0, in_max: frame.height, out_min: -1.0, out_max: 1.0) - 1
            bgGradient.draw(in: dirtyRect, relativeCenterPosition: NSPoint(x: newPointX, y: newPointY))
        } else if (typeOfRad == X) {
            for i in 0..<(colorArray.count*2) {
                let index = (i < colorArray.count) ? i : (i - colorArray.count)
                let color = colorArray[index]
                let newPointX = KeysView.map(x: crosshairLocation!.x, in_min: 0, in_max: frame.width, out_min: 0.0, out_max: 1.0)
                var location: CGFloat
                if (i < colorArray.count) {
                    location = (newPointX/CGFloat(colorArray.count) * CGFloat(i))
                } else {
                    location = newPointX + (((1.0 - newPointX) / CGFloat(colorArray.count)) * CGFloat(index))
                }
                newColorArray.append(color.withAlphaComponent(0.70))
                newLocation.append(location)
            }

            let bgGradient = NSGradient(colors: newColorArray, atLocations: newLocation, colorSpace: .genericRGB)!
            bgGradient.draw(in: dirtyRect, angle: 0.0)
        } else {
            for i in 0..<(colorArray.count*2) {
                let index = (i < colorArray.count) ? i : (i - colorArray.count)
                let color = colorArray[index]
                let newPointY = KeysView.map(x: crosshairLocation!.y, in_min: 0, in_max: frame.height, out_min: 0.0, out_max: 1.0)
                var location: CGFloat
                if (i < colorArray.count) {
                    location = (newPointY/CGFloat(colorArray.count) * CGFloat(i))
                } else {
                    location = newPointY + (((1.0 - newPointY) / CGFloat(colorArray.count)) * CGFloat(index))
                }
                newColorArray.append(color.withAlphaComponent(0.70))
                newLocation.append(location)
            }

            let bgGradient = NSGradient(colors: newColorArray, atLocations: newLocation, colorSpace: .genericRGB)!
            bgGradient.draw(in: dirtyRect, angle: 90)
        }
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        context.addEllipse(in: CGRect(origin: CGPoint(x: crosshairLocation.x-crosshairSize.width/2, y: crosshairLocation.y-crosshairSize.height/2),
                                      size: crosshairSize))
        context.addLines(between: [CGPoint(x: crosshairLocation.x, y: crosshairLocation.y-14),
                                   CGPoint(x: crosshairLocation.x, y: crosshairLocation.y+14)])
        context.addLines(between: [CGPoint(x: crosshairLocation.x-14, y: crosshairLocation.y),
                                   CGPoint(x: crosshairLocation.x+14, y: crosshairLocation.y)])
        context.strokePath()
    }
    
    // Returns value of the coordinates in respect to SSEngine's calculations
    func getCalculatedOrigin() -> KeyPoint {
        let flipYAxis = frame.height - crosshairLocation.y
        let x = UInt16(KeysView.map(x: crosshairLocation.x, in_min: 0, in_max: frame.width, out_min: 0, out_max: 0x10c5))
        let y = UInt16(KeysView.map(x: flipYAxis, in_min: 0, in_max: frame.height, out_min: 0, out_max: 0x040d))
        return KeyPoint(x: x, y: y)
    }
    
    func setFromKey(transitions: UnsafeMutablePointer<KeyTransition>, count: UInt8, radType: WaveRadControl, origin: KeyPoint) {
        let colorArr: [NSColor] = []
        for i in 0..<Int(count) {
            let transition = transitions[i]
            colorArray.append(transition.color.nsColor)
        }
        
        setOrigin(origin: origin)
        colorArray = colorArr
        typeOfRad = radType;
    }
    
    func setDefaultView() {
        crosshairLocation = NSPoint(x: frame.width/2, y: frame.height/2)
        typeOfRad = XY
    }
    
    private func setOrigin(origin: KeyPoint) {
        let flipYAxis =  0x040d - origin.y
        let x = KeysView.map(x: CGFloat(origin.x), in_min: 0, in_max: 0x10c5, out_min: 0, out_max: frame.width)
        let y = KeysView.map(x: CGFloat(flipYAxis), in_min: 0, in_max: 0x040d, out_min: 0, out_max: frame.height)

        crosshairLocation = calcBounds(point: NSPoint(x: x, y: y))
        needsDisplay = true
    }
}
