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
        let seconds = self.timeIntervalSinceNow
        if seconds < 1.minute {
            return "\(seconds)\u{2009}秒"
        } else {
            return String(format: "%.1f\u{2009}分", seconds/1.minute)
        }
    }
}
