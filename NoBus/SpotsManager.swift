//
//  SpotsManager.swift
//  NoBus
//
//  Created by Gao on 2018/10/25.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import fucking_beijing_bus_api
import Alamofire

class SpotsManager {
    static let shared = SpotsManager()
    
    func getAllSpot(c:@escaping ([Spot])->Void)  {
        //TODO
        let wanted = ["478", "运通103", "632"]
        let API = BeijingBusAPI.Static.Cache.self
        API.getAllLinesSmartly { (result) in
            guard let lineMetas = result.value else {
                return
            }
            let lines = lineMetas.filter { meta in
                wanted.contains(meta.busNumber)
            }
            SpotsManager.getLineDetails(IDs: lines, completion: { (details) in
                 let stations = details.compactMap({ d in
                    let s = d.stations.first(where: { (s) -> Bool in
                        s.name == "学知园"
                    })
                    let station = Station(line: d, stationIndex: s?.index ?? 1000)
                    return station
                 }).filter({ (station:Station) -> Bool in
                    station.nextStation?.name == "静淑苑"
                 })
                let generalStation = GeneralStation(stations: stations)
                let spot = Spot(stations: [generalStation])
                c([spot])
            })
        }
    }
    
    private static func getLineDetails(IDs:[LineMeta], completion:@escaping ([LineDetail])->Void) {
        let group = DispatchGroup()
        var details = [LineDetail]()
        group.enter()
        group.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            completion(details)
        }))
        for id in IDs {
            group.enter()
            BeijingBusAPI.Static.Cache.getLineDetailSmartly(ofLine: id.ID) { (result:Result<LineDetail?>) in
                result.withValue({ (detail) in
                    if let d = detail {
                        details.append(d)
                    }
                })
                group.leave()
            }
        }
        group.leave()
        
    }
}
