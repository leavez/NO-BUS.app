//
//  Time.swift
//  NoBus
//
//  Created by Gao on 2018/11/13.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation

/**
 USAGE:
 let a:TimeInterval = 10.minute // 600s
 let b = 1.5.hour               // 5400s
 
 let now = 0.second.later
 let t1: Date = 5.minite.later
 let t2 = 5.minite.ago
 let t3 = 1.day.ago
 1et t4 = year.later
 */


public protocol Time {
    var doubleValue: Double {get}
}
extension Time {
    public var second: TimeInterval {
        return self.doubleValue
    }
    public var millisecond: TimeInterval {
        return 0.001 * second
    }
    public var minute: TimeInterval {
        return 60 * second
    }
    public var hour: TimeInterval {
        return 60 * minute
    }
    public var day: TimeInterval {
        return 24 * hour
    }
    public var week: TimeInterval {
        return 7 * day
    }
    public var year: TimeInterval {
        return 365 * day
    }
    
}

extension TimeInterval {
    
    public var later: Date {
        return Date(timeIntervalSinceNow: self)
    }
    public var ago: Date {
        return Date(timeIntervalSinceNow: -self)
    }
}

extension Int: Time {
    public var doubleValue: Double {
        return Double(self)
    }
}
extension Double: Time {
    public var doubleValue: Double {
        return Double(self)
    }
}
