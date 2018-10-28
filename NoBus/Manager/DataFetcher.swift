//
//  DataFetcher.swift
//  NoBus
//
//  Created by Gao on 2018/10/26.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
@_exported import fucking_beijing_bus_api
@_exported import Alamofire

struct DataFetcher {
    
    static func getStatus(for spots:[Spot],
                          completion:@escaping (Result<[String:BusStatusForStation]>)->Void)
    {
        let stations = spots.flatMap {
            $0.stations.flatMap({
                $0.stationsInLines
            })
        }
        self.getStatus(for: stations, completion: completion)
    }
    
    
    
    static func getStatus(for stations:[Station],
                          completion:@escaping (Result<[String:BusStatusForStation]>)->Void)
    {
        let parameters = stations.map({ s in
            (s.belongedToLine.ID, s.name, s.apiObject.index)
        })
        
        BeijingBusAPI.RealTime.getLineStatusForStation(parameters, completion: { (result) in
            let newResult = result.map { stations in
                return stations.reduce([:], { (sum, s) -> [String: BusStatusForStation] in
                    var dict = sum
                    if let lineID = s.lineID {
                        dict[lineID] = s
                    }
                    return dict
                })
            }
            completion(newResult)
        })
    }

}
