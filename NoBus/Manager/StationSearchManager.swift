//
//  StationSearchManager.swift
//  NoBus
//
//  Created by Gao on 2018/11/14.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class StationSearchManager {
    
    static let shared = StationSearchManager()
    
    func warmUpCache() {
        self.queue.async {
            BeijingBusAPI.Static.Cache.getAllLinesSmartly { (_) in }
        }
    }
    
    func search(fuzzyStationName: String?, lineNumber: String?) -> Observable<[Station]?> {

        if ([fuzzyStationName, lineNumber].compactMap{ $0 }.filter{ $0.count > 0}).isEmpty {
            return Observable.just([])
        }
        
        return Observable.create {[unowned self] (observer) -> Disposable in
            
            self.queue.async {
                let API = BeijingBusAPI.Static.Cache.self
                API.getAllLinesSmartly { (result) in
                    guard let lineMetas = result.value else {
                        // error will be not nil if value is nil
                        observer.onError(result.error!)
                        return
                    }
                    let lines: [LineMeta]
                    if let lineNumber = lineNumber {
                        lines = lineMetas.filter { meta in
                            meta.busNumber.contains(lineNumber)
                        }
                    } else {
                        lines = lineMetas
                    }
                    if lines.count > 5 {
                        observer.onNext([])
                        observer.onCompleted()
                        return
                    }
                    StationSearchManager.getLineDetails(IDs: lines, completion: { (details) in
                        let stations = details.flatMap({ (lineDetail) -> [Station] in
                            let stations = lineDetail.stations.filter {
                                isFuzzyMatchName($0.name, fuzzyStationName)
                            }
                            return stations.compactMap {
                                Station(line: lineDetail, stationIndex: $0.index)
                            }
                        })
                        if stations.count == 0 {
                            observer.onNext(nil)
                        } else {
                            observer.onNext(stations)
                        }
                        observer.onCompleted()
                    })
                }
            }
            
            return Disposables.create()
        }
    }
    
    private init() {}
    
    private let queue = DispatchQueue(label: "search queue")
    
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

private func isFuzzyMatchName(_ target:String, _ input:String?) -> Bool  {
    guard let input = input else { return true }
    //todo pinyin
    //fuzzy
    return target.contains(input) || input.contains(target)
}
