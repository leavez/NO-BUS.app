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
    var subDescription: UIColor { get }
}

struct RedTable: ColorTable {
    var title: UIColor {
        return UIColor(hexString: "fb6542")
    }
    var largeTitle: UIColor {
        return title.light
    }
    var subDescription: UIColor {
        return UIColor(white: 0.5, alpha: 1)
    }
}


extension UIColor {
    
    var light: UIColor {
        return self.withAlphaComponent(0.7)
    }
}
