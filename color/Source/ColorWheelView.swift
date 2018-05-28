//
//  ColorWheelView.swift
//  color
//
//  Created by Codegreen on 02/04/2018.
//  Copyright © 2018 Codegreen. All rights reserved.


import UIKit

public protocol ColorWheelProtocol {
    func colorPick(color: UIColor)
}

@IBDesignable
public class ColorWheelView: UIView {
    /// wheel center with scale
    private var wCenters: CGPoint = CGPoint.zero
    /// wheel width with scale
    private var wWidths: Int = 0
    /// wheel height with scale
    private var wHeights: Int = 0
    /// wheel radius with scale
    private var wRadiuss: CGFloat = 0
    private var scale = UIScreen.main.scale
    private var wheelImageView: UIImageView?
    private var shadow: UIView!
    private var picker: UIView!
    private var lastLocation: CGPoint!

    private var brightnessVal: CGFloat = 1
    @IBInspectable
    public var brightness: CGFloat {
        get {return self.brightnessVal}
        set {
            if newValue > 1.0 {
                self.brightnessVal = 1.0
            } else if newValue < 0.0 {
                self.brightnessVal = 0.0
            } else {
                self.brightnessVal = newValue
            }
            self.shadow.alpha = 1 - self.brightnessVal
            self.sendRGBValue(x: self.picker.center.x * self.scale,
                              y: self.picker.center.y * self.scale)
        }
    }

    var delegate: ColorWheelProtocol?

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
        var rect: CGRect = self.bounds
        if rect.width != rect.height {
            let minVal: CGFloat = min(rect.width, rect.height)
            rect = CGRect(origin: frame.origin,
                          size: CGSize(width: minVal,
                                       height: minVal))
        }

        self.setup(rect: rect)
        self.setColorWheel()
        self.setColorPicker()

        self.sendRGBValue(x: self.picker.center.x * self.scale,
                          y: self.picker.center.y * self.scale)
    }

    private func setup(rect: CGRect) {
    self.layer.borderWidth = 0
    self.layer.cornerRadius = 0.5 * rect.size.width
    self.layer.masksToBounds = true
    self.backgroundColor = UIColor.white

    self.wRadiuss = rect.width / 2 * self.scale
    self.wWidths = Int(rect.width * self.scale)
    self.wHeights = Int(rect.height * self.scale)
    self.wCenters = CGPoint(x: self.bounds.width * self.scale / 2,
                           y: self.bounds.height * self.scale / 2)
    }
}

// MARK: Color wheel related
extension ColorWheelView {
    private func setColorWheel() {
        let circleImg = self.buildHueCircle()
        if self.wheelImageView != nil {
            self.wheelImageView!.image = circleImg
        } else {
            self.wheelImageView = UIImageView(image: circleImg)
            self.insertSubview(self.wheelImageView!, at: 0)
            self.createShadow()
        }
    }

    private func buildHueCircle() -> UIImage? {

        let space = CGColorSpaceCreateDeviceRGB()
        let bWidth = Int(self.bounds.width * self.scale)
        let bHeight = Int(self.bounds.height * self.scale)
        let context = CGContext(data: nil, width: bWidth, height: bHeight, bitsPerComponent: 8, bytesPerRow: bWidth * 4, space: space, bitmapInfo: Pixel.bitmapInfo)!

        let buffer = context.data!

        let pixels = buffer.bindMemory(to: Pixel.self, capacity: bWidth * bHeight)
        let heightStart = Int(self.wCenters.y - 0.5 * CGFloat(self.wHeights))
        let widthStart = Int(self.wCenters.x - 0.5 * CGFloat(self.wWidths))
        for y in heightStart ..< heightStart + self.wHeights {
            for x in widthStart ..< widthStart + self.wWidths {
                let pixel = self.pixel(y: y, x: x)
                pixels[y * bWidth + x] = pixel
            }
        }

        let cgImage = context.makeImage()!
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: .up)
    }

    private func pixel(y: Int, x: Int) -> Pixel{
        var pixel: Pixel
        let angle = fmod(atan2(CGFloat(y) - self.wCenters.y, CGFloat(x) - wCenters.x) + 2 * .pi, 2 * .pi)
        let distance = hypot(CGFloat(x) - wCenters.x, CGFloat(y) - wCenters.y)
        let saturation = min(1, distance / CGFloat(self.wWidths) * self.scale)

        let value = UIColor(hue: angle / 2 / .pi, saturation: saturation, brightness: 1, alpha: 1)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        value.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        if distance <= self.wRadiuss {
            pixel = Pixel(red:   UInt8(red * 255.0),
                          green: UInt8(green * 255.0),
                          blue:  UInt8(blue * 255.0),
                          alpha: UInt8(alpha * 255.0))
        } else {
            pixel = Pixel(red: 255, green: 255, blue: 255, alpha: 0)
        }
        return pixel
    }

    private func createShadow() {
        let width = CGFloat(self.wWidths) / self.scale
        let frame = CGRect(x: 0, y: 0, width: width, height: width)
        self.shadow = UIView(frame: frame)
        self.shadow.backgroundColor = UIColor.black
        self.shadow.layer.cornerRadius = 0.5 * width
        self.shadow.alpha = 0
        self.insertSubview(self.shadow,
                           aboveSubview: self.wheelImageView!)
    }
}

// MARK: Color picker
extension ColorWheelView {
    private func setColorPicker() {
        let frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        self.picker = UIView(frame: frame)
        let size = self.bounds.size
        self.picker.center = CGPoint(x: size.width/2, y: size.height/2)
        self.picker.layer.cornerRadius = 9
        self.picker.layer.masksToBounds = false
        self.picker.layer.borderColor = UIColor.black.cgColor
        self.picker.layer.borderWidth = 0.5
        self.picker.backgroundColor = UIColor.clear
        self.drawCross(view: self.picker)
        self.addSubview(self.picker)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.detectPan(ges:)))
        self.picker.addGestureRecognizer(pan)
    }

    private func drawCross(view: UIView) {
        let line1 = CALayer()
        line1.frame = CGRect(x: view.bounds.width/2, y: 0, width: 0.5, height: view.bounds.height)
        line1.backgroundColor = UIColor.black.cgColor
        view.layer.addSublayer(line1)

        let line2 = CALayer()
        line2.frame = CGRect(x: 0, y: view.bounds.height/2, width: view.bounds.width, height: 0.5)
        line2.backgroundColor = UIColor.black.cgColor
        view.layer.addSublayer(line2)
    }

    @objc private func detectPan(ges: UIPanGestureRecognizer) {
        if ges.state == .began {
            self.lastLocation = self.picker.center
        } else {
            let translation  = ges.translation(in: self)
            let x = self.lastLocation.x + translation.x
            let y = self.lastLocation.y + translation.y
            let dis = hypot(CGFloat(x * self.scale) - self.wCenters.x, CGFloat(y * self.scale) - self.wCenters.y)
            if dis <= self.wRadiuss {
                self.picker.center = CGPoint(x: x, y: y)
                self.sendRGBValue(x: x * self.scale,
                                  y: y * self.scale)
            }
        }
    }

    private func sendRGBValue(x: CGFloat, y: CGFloat) {
        let pixel = self.pixel(y: Int(y),
                               x: Int(x))
        let red = CGFloat(pixel.red)
        let green = CGFloat(pixel.green)
        let blue = CGFloat(pixel.blue)
        let color = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: CGFloat(pixel.alpha)/255.0)

        var hue: CGFloat = 0
        var sat: CGFloat = 0
        color.getHue(&hue, saturation: &sat, brightness: nil, alpha: nil)
        let real = UIColor(hue: hue, saturation: sat, brightness: self.brightnessVal, alpha: 1)
        self.delegate?.colorPick(color: real)
    }
}
