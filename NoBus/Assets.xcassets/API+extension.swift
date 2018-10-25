//
//  API+extension.swift
//  NoBus
//
//  Created by Gao on 2018/10/25.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import fucking_beijing_bus_api

extension LineDetail: CustomDebugStringConvertible {
    public var debugDescription: String {
        return self.busNumber + ": " + self.departureStationName + " - " + self.terminalStationName
    }
}

extension LineDetail.Station : CustomDebugStringConvertible {
    public var debugDescription: String {
        return String(format: "%@ (%d)", name, index)
    }
}

extension Coordinate: CustomDebugStringConvertible {
    public var debugDescription: String {
        return String(format: "(%f, %f)", latitude,longitude)
    }
}
