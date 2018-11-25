//
//  UIColor+Extension.swift
//  NoBus
//
//  Created by Gao on 2018/11/25.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit


extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let scanner = Scanner(string: hexString)
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
