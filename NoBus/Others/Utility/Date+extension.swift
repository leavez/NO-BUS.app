//
//  Date+extension.swift
//  NoBus
//
//  Created by Gao on 2018/11/13.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation

extension Date {
    var pastDurationDescription: String {
        let seconds = -self.timeIntervalSinceNow // self is furture
        return convertToDescribable(seconds)
    }
    var furtureDurationDescription: String {
        let seconds = self.timeIntervalSinceNow // self is furture
        return convertToDescribable(seconds)
    }
    
    private func convertToDescribable(_ seconds: TimeInterval ) -> String {
        if seconds < 1.minute {
            return String(format:"%.0f\u{2009}秒", seconds)
        } else {
            return String(format: "%.1f\u{2009}分钟", seconds/1.minute)
        }
    }
}
