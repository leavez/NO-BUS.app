//
//  API+extension.swift
//  NoBus
//
//  Created by Gao on 2018/10/25.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import fucking_beijing_bus_api
import CoreLocation

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

extension Coordinate {
    public var CLCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

extension LineDetail {
    var parsedLineCoordinates: [CLLocationCoordinate2D] {
        let pairs = self.coords.split(separator: ",").reduce(([], nil)) { (sum, new) -> ([(Substring, Substring)], Substring?) in
            if let last = sum.1 {
                return (sum.0 + [(last,new)] , nil)
            } else {
                return (sum.0, new)
            }
        }.0
        return pairs.compactMap {
            if let lat = Double($0.1),
                let long = Double($0.0) {
                return CLLocationCoordinate2D(latitude: lat, longitude: long)
            } else {
                return nil
            }
        }
    }
}

