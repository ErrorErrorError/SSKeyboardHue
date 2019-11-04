//
//  ColorUtils.swift
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/3/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

import Cocoa
// From SSKeyboard.h
extension RGB {
    public var nsColor: NSColor {
        get {
            return NSColor(red: CGFloat(Double(self.r)/255.0), green: CGFloat(Double(self.g)/255.0), blue: CGFloat(Double(self.b)/255.0), alpha: 1.0)
        }
        set(newColor) {
            self.r = UInt8(newColor.redComponent * 255)
            self.g = UInt8(newColor.greenComponent * 255)
            self.b = UInt8(newColor.blueComponent * 255)
        }
    }
    
    static func == (lhs: RGB, rhs: RGB) -> Bool {
        return lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b
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

// Extension is from https://github.com/Gofake1/Color-Picker/blob/master/Color%20Picker/NSColor%2B.swift
extension NSColor {
    var getRGB: RGB {
        var color: RGB = RGB()
        color.r = UInt8(round(self.redComponent * 0xFF))
        color.g = UInt8(round(self.greenComponent * 0xFF))
        color.b = UInt8(round(self.blueComponent * 255))
        return color
    }
    var rgbHexString: String {
        guard let rgbColor = usingColorSpace(NSColorSpace.genericRGB) else { return "FFFFFF" }
        
        let r = UInt8(round(rgbColor.redComponent * 0xFF))
        let g = UInt8(round(rgbColor.greenComponent * 0xFF))
        let b = UInt8(round(rgbColor.blueComponent * 0xFF))
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
    
    // from https://gist.github.com/mbigatti/c6be210a6bbc0ff25972
    func lighterColor(percent : Double) -> NSColor {
        return colorWithBrightnessFactor(factor: CGFloat(1 + percent));
    }
    
    /**
     Returns a darker color by the provided percentage
     
     :param: darking percent percentage
     :returns: darker UIColor
     */
    func darkerColor(percent : Double) -> NSColor {
        return colorWithBrightnessFactor(factor: CGFloat(1 - percent));
    }
    
    /**
     Return a modified color using the brightness factor provided
     
     :param: factor brightness factor
     :returns: modified color
     */
    func colorWithBrightnessFactor(factor: CGFloat) -> NSColor {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return NSColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
        
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
