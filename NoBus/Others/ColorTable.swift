//
//  ColorTable.swift
//  NoBus
//
//  Created by Gao on 2018/11/25.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var table: ColorTable {
        return RedTable()
    }
}

protocol ColorTable {
    var title: UIColor { get }
    var largeTitle: UIColor { get }
    var plainTitle: UIColor { get }
    var subDescription: UIColor { get }
    
    var background: UIColor { get }
    var cardBackgroud: UIColor { get }
    
    var cardBorder: CGColor { get }
    var cardBorderLight: CGColor { get }
    var cardShadowHeavy: CGColor { get }
    
}

struct RedTable: ColorTable {
    var title: UIColor {
        return UIColor(hexString: "fb6542")
    }
    var largeTitle: UIColor {
        return title.light
    }
    var plainTitle: UIColor {
        return UIColor(white: 0.1, alpha: 1)
    }
    var subDescription: UIColor {
        return UIColor(white: 0.5, alpha: 1)
    }
    var background: UIColor {
        return .white
    }
    var cardBackgroud: UIColor {
        return .white
    }
    
    var cardBorderLight: CGColor {
        return UIColor(white: 0.9, alpha: 0.7).cgColor
    }
    var cardBorder: CGColor {
        return UIColor(white: 0.8, alpha: 0.3).cgColor
    }
    var cardShadowHeavy: CGColor {
        return UIColor.darkGray.cgColor
    }
}


extension UIColor {
    
    var light: UIColor {
        return self.withAlphaComponent(0.7)
    }
}
