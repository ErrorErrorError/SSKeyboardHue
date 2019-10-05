//
//  ColorUtils.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/3/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa

/*
public struct RGB {
    
    public var r: uint8
    
    public var g: uint8
    
    public var b: uint8
    
    public var a: uint8
    
    public var nsColor: NSColor {
        mutating get {
            return NSColor(red: CGFloat(Double(self.r)/255.0), green: CGFloat(Double(self.g)/255.0), blue: CGFloat(Double(self.b)/255.0), alpha: CGFloat(Double(self.a)/255.0))
        }
        set(newColor) {
            self.r = UInt8(newColor.redComponent * 255)
            self.g = UInt8(newColor.greenComponent * 255)
            self.b = UInt8(newColor.blueComponent * 255)
            self.a = UInt8(newColor.alphaComponent * 255)
        }
    }
    
    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}
 */

public struct RGB {
    
    public var r: uint8
    
    public var g: uint8
    
    public var b: uint8
    
    public var nsColor: NSColor {
        mutating get {
            return NSColor(red: CGFloat(Double(self.r)/255.0), green: CGFloat(Double(self.g)/255.0), blue: CGFloat(Double(self.b)/255.0), alpha: 1.0)
        }
        set(newColor) {
            self.r = UInt8(newColor.redComponent * 255)
            self.g = UInt8(newColor.greenComponent * 255)
            self.b = UInt8(newColor.blueComponent * 255)
        }
    }
    
    public init(r: UInt8, g: UInt8, b: UInt8) {
        self.r = r
        self.g = g
        self.b = b
    }
}
public struct HSV {
    
    public var h: UInt16
    
    public var s: UInt8
    
    public var b: UInt8
    
    public var a: UInt8
    
    public var nsColor: NSColor {
        mutating get {
            return NSColor(hue: CGFloat(Double(self.h)/360), saturation: CGFloat(Double(self.s)/255.0), brightness: CGFloat(Double(self.b)/255.0), alpha: CGFloat(Double(self.a)/255.0))
        }
        set(newColor) {
            self.h = UInt16(newColor.hueComponent * 360)
            self.s = UInt8(newColor.saturationComponent * 255)
            self.b = UInt8(newColor.brightnessComponent * 255)
            self.a = UInt8(newColor.alphaComponent * 255)
        }
    }
    
    public init(h: UInt16, s: UInt8, b: UInt8, a: UInt8) {
        self.h = h
        self.s = s
        self.b = b
        self.a = a
    }
}


extension NSColor {
    
    var rgbHexString: String {
        guard let rgbColor = usingColorSpace(NSColorSpace.genericRGB) else { return "FFFFFF" }
        
        let r = Int(round(rgbColor.redComponent * 0xFF))
        let g = Int(round(rgbColor.greenComponent * 0xFF))
        let b = Int(round(rgbColor.blueComponent * 0xFF))
        return String(format: "%02X%02X%02X", r, g, b)
    }
    
    var rgbDecString: String {
        guard let rgbColor = usingColorSpace(NSColorSpace.genericRGB) else { return "1.0 1.0 1.0" }
        return "\(rgbColor.redComponent) \(rgbColor.greenComponent) \(rgbColor.blueComponent)"
    }
    
    var cmykString: String {
        guard let cmykColor = usingColorSpace(NSColorSpace.genericRGB) else { return "0.0 0.0 0.0 0.0" }
        return "\(cmykColor.cyanComponent) \(cmykColor.magentaComponent) \(cmykColor.yellowComponent) " +
        "\(cmykColor.blackComponent)"
    }
    
    // Workaround: `NSColor`'s `brightnessComponent` is sometimes a value in [0-255] instead of in [0-1]
    /// Brightness value scaled between 0 and 1
    var scaledBrightness: CGFloat {
        if brightnessComponent > 1.0 {
            return brightnessComponent/255.0
        } else {
            return brightnessComponent
        }
    }
    
    /// - precondition: `hexString` contains six characters or seven if prefixed with `#`
    convenience init(hexString: String) {
        var hexString = hexString
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        guard let hexInt = Int(hexString, radix: 16) else {
            self.init(red: 1, green: 1, blue: 1, alpha: 1)
            return
        }
        self.init(red:   CGFloat((hexInt >> 16) & 0xFF) / 255.0,
                  green: CGFloat((hexInt >> 8) & 0xFF) / 255.0,
                  blue:  CGFloat((hexInt >> 0) & 0xFF) / 255.0,
                  alpha: 1)
    }
    
    convenience init(coord: (x: Int, y: Int), center: (x: Int, y: Int), brightness: CGFloat) {
        let angle      = atan2(CGFloat(center.x - coord.x), CGFloat(center.y - coord.y)) + CGFloat.pi
        let distance   = sqrt(pow(CGFloat(center.x - coord.x), 2) + pow(CGFloat(center.y - coord.y), 2))
        let hue        = max(min(angle / (CGFloat.pi * 2), 1), 0)
        let saturation = max(min(distance / CGFloat(center.x), 1), 0)
        self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

extension NSColor: Comparable {
    public static func < (lhs: NSColor, rhs: NSColor) -> Bool {
        if lhs.hueComponent == rhs.hueComponent {
            return lhs.brightnessComponent < rhs.brightnessComponent
        } else {
            return lhs.hueComponent < rhs.hueComponent
        }
    }
}
