//
//  ColorSlider.swift
//  color
//
//  Created by 陳建佑 on 10/04/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

public protocol ColorSliderProtocol: AnyObject {
    func colorSlider(bright: CGFloat)
}

@IBDesignable
public class ColorSlider: UIView {

    weak var delegate: ColorSliderProtocol?

    private var colorVal: UIColor = UIColor.white
    @IBInspectable
    public var selectedColor: UIColor {
        set {
            self.colorVal = newValue
            self.createBackground()
        }
        get {
            return self.colorVal
        }
    }

    private var background: UIImageView?
    /// width with scale
    private var widths: Int!
    /// height with scale
    private var heights: Int!
    private var scale = UIScreen.main.scale
    private var thumb: UIView!
    private var lastLocation: CGPoint!
    private let gray = UIColor(red: 0.596, green: 0.596, blue: 0.596, alpha: 1)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        guard self.bounds != CGRect.zero else {
            // avoid error when xib preview
            return
        }
        self.prepare()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        guard self.bounds != CGRect.zero else {
            // avoid error when xib preview
            return
        }
        self.prepare()
    }

    override public func prepareForInterfaceBuilder() {
        // For storyboard/ xib only
        // won't run at program initialization
        self.prepare()
    }

    private func prepare() {
        self.widths = Int(self.bounds.width * self.scale)
        self.heights = Int(self.bounds.height * self.scale)
        self.createBackground()
        self.createThumb()
    }
}

// MARK: background
extension ColorSlider {
    private func createBackground() {
        if self.background != nil {
            self.background!.removeFromSuperview()
        }

        let space = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: self.widths, height: self.heights, bitsPerComponent: 8, bytesPerRow: self.widths * 4, space: space, bitmapInfo: Pixel.bitmapInfo)!

        let buffer = context.data!

        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var alpha: CGFloat = 0
        self.colorVal.getHue(&hue, saturation: &sat, brightness: nil, alpha: &alpha)
        let fWidths = CGFloat(self.widths)

        let pixels = buffer.bindMemory(to: Pixel.self, capacity: self.widths * self.heights)
        for y in 0 ..< self.heights {
            for x in 0 ..< self.widths {
                let bright = 1 - CGFloat(x) / fWidths
                let pixel = self.pixel(hue: hue, sat: sat, alpha: alpha, bright: bright)
                pixels[y * self.widths + x] = pixel
            }
        }

        let cgImage = context.makeImage()!
        let img = UIImage(cgImage: cgImage, scale: self.scale, orientation: .up)
        self.background = UIImageView(image: img)
        self.background!.layer.borderColor = self.gray.cgColor
        self.background!.layer.borderWidth = 1
        self.background!.layer.cornerRadius = 0.5 * self.bounds.height
        self.background!.layer.masksToBounds = true
        self.insertSubview(self.background!, at: 0)
    }

    private func pixel(hue: CGFloat, sat: CGFloat, alpha: CGFloat, bright: CGFloat) -> Pixel {
        let value = UIColor(hue: hue, saturation: sat, brightness: bright, alpha: alpha)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        value.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let pixel = Pixel(red:   UInt8(red * 255.0),
                          green: UInt8(green * 255.0),
                          blue:  UInt8(blue * 255.0),
                          alpha: UInt8(alpha * 255.0))
        return pixel
    }
}

// MARK: thumb
extension ColorSlider {
    private func createThumb() {
        let frame = CGRect(x: 0, y: 0, width: 1.5*self.bounds.height, height: 1.5*self.bounds.height)
        self.thumb = UIView(frame: frame)
        self.thumb.layer.cornerRadius = 0.5 * frame.height
        self.thumb.layer.borderColor = self.gray.cgColor
        self.thumb.layer.borderWidth = 1
        self.thumb.layer.backgroundColor = UIColor.white.cgColor
        self.thumb.center = CGPoint(x: 0,
                                    y: 0.5 * self.bounds.height)
        self.addSubview(self.thumb)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.detectPan(ges:)))
        self.thumb.addGestureRecognizer(pan)
    }

    @objc private func detectPan(ges: UIPanGestureRecognizer) {
        if ges.state == .began {
            self.lastLocation = self.thumb.center
        } else {
            let translation  = ges.translation(in: self)
            var x = max(0, self.lastLocation.x + translation.x)
            x = min(x, self.bounds.width)
            self.thumb.center = CGPoint(x: x, y: self.thumb.center.y)
            self.delegate?.colorSlider(bright: 1 - x/self.bounds.width)
        }
    }
}
