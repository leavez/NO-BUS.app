//
//  Date+extension.swift
//  NoBus
//
//  Created by Gao on 2018/11/13.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation

extension Date {
    var readableDescriptionToNow: String {
        let seconds = -self.timeIntervalSinceNow // self is furture 
        if seconds < 1.minute {
            return String(format:"%.0f\u{2009}秒", seconds)
        } else {
            return String(format: "%.1f\u{2009}分钟", seconds/1.minute)
        }
    }
}
