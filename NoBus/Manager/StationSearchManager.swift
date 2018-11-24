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
    
    /// Search the stations
    ///
    /// return nil means no result.
    /// return [] means search have not real started.
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
                    if lines.count > 5 && (lineNumber == nil || lineNumber!.count < 3) {
                        observer.onNext([])
                        observer.onCompleted()
                        return
                    }
                    StationSearchManager.getLineDetails(IDs: lines, completion: { (details) in
                        self.queue.async {
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
                        }
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
    guard var input = input else { return true }
    
    
    func tranformToPinyin(_ s: String) -> String {
        if let saved = cache.object(forKey: s as NSString) {
            return saved as String
        }
        let new = (s as String).transformToPinYin()
        cache.setObject(new as NSString, forKey: s as NSString)
        return new
    }
    // pinyin    
    let latinInput = tranformToPinyin(input).lowercased()
    let latinTarget = tranformToPinyin(target).lowercased()
    return latinTarget.contains(latinInput) || latinInput.contains(latinTarget)
}

private let cache: NSCache<NSString, NSString> = {
    let c = NSCache<NSString, NSString>()
    c.countLimit = 300
    return c
}()
