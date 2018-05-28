//
//  Pixel.swift
//  color
//
//  Created by 陳建佑 on 10/04/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
import UIKit

struct Pixel: Equatable {
    private var rgba: UInt32

    var red: UInt8 {
        return UInt8((rgba >> 24) & 255)
    }

    var green: UInt8 {
        return UInt8((rgba >> 16) & 255)
    }

    var blue: UInt8 {
        return UInt8((rgba >> 8) & 255)
    }

    var alpha: UInt8 {
        return UInt8((rgba >> 0) & 255)
    }

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        let red32 = UInt32(red)
        let green32 = UInt32(green)
        let blue32 = UInt32(blue)
        let alpha32 = UInt32(alpha)
        rgba = red32 << 24 | green32 << 16 | blue32 << 8 | alpha32
    }

    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

    static func ==(lhs: Pixel, rhs: Pixel) -> Bool {
        return lhs.rgba == rhs.rgba
    }
}
