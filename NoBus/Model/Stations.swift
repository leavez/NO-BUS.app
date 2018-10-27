//
//  Spot.swift
//  NoBus
//
//  Created by Gao on 2018/10/24.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import fucking_beijing_bus_api

// another representation of LineDetail.Station
struct Station {
    var name: String {
        return apiObject.name
    }
    let nextStation: LineDetail.Station?
    let apiObject: LineDetail.Station
    let belongedToLine: LineDetail
    
    init?(line: LineDetail, stationIndex: Int) {
        let realIndex = stationIndex - 1
        guard realIndex < line.stations.count else {
            return nil
        }
        belongedToLine = line
        apiObject = line.stations[realIndex]
        
        if realIndex + 1 < line.stations.count {
            nextStation = line.stations[realIndex + 1]
        } else {
            nextStation = nil
        }
    }
}


/// API 中车站是附属于线路的，这里的 model 是以车站为出发点看的
struct GeneralStation {
    let name: String
    let stationsInLines: [Station]
    
    init(stations:[Station]) {
        assert(stations.count > 0)
        stationsInLines = stations
        name = stations.first!.name
    }
}


/// 表示一个习惯上车的物理地点，可能包含多个物理车站（比如大厦的两侧都有车站）
struct Spot {
    let stations: [GeneralStation]
    
    init(stations: [GeneralStation]) {
        self.stations = stations
    }
}


extension GeneralStation: Codable {}
extension Spot: Codable {}
extension Station: Codable {}
