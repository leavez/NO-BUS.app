//
//  StationsManager.swift
//  NoBus
//
//  Created by leave on 2018/11/15.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import RxSwift

class StationsManager {
    
    static let shared = StationsManager()
    
    private(set) lazy var allStations: BehaviorSubject<[GeneralStation]> = {
        return BehaviorSubject<[GeneralStation]>(value: self.cached)
    }()
    
    func allSavedStationsAndLines() -> [GeneralStation] {
        return cached
    }
    
    func addToSaved(station: Station) {
        var generalStations = cached
        let hit = generalStations.first { (gs) -> Bool in
            gs.name == station.name
        }
        if let hit = hit {
            if hit.stationsInLines.index(where: { $0 == station}) == nil {
                hit.stationsInLines.append(station)
            }
        } else {
            let new = GeneralStation(stations: [station])
            generalStations.append(new)
        }
        cached = generalStations
    }
    
    func removeFromSaved(station: Station) {
        var generalStations = cached
        let hit = generalStations.first { $0.name == station.name }
        guard let general = hit else {
            return
        }
        
        let index = general.stationsInLines.index(where:{ $0 == station })
        if let index = index {
            general.stationsInLines.remove(at: index)
            if general.stationsInLines.isEmpty {
                _ = generalStations.index(where:{ $0.name == general.name}).map { index -> Bool in
                    generalStations.remove(at: index)
                    return true
                }
            }
        }
        cached = generalStations
    }
    
    func removeAll() {
        self.cached = []
    }
    
    private let key = "com.leavez.nobus.stations.saved"
    
    private var cached: [GeneralStation] {
        set {
            checkThread()
            _cached = newValue
            let data = try? encoder.encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
        get {
            checkThread()
            if let c = _cached {
                return c
            } else {
                guard let data = UserDefaults.standard.data(forKey: key) else {
                    _cached = []
                    return []
                }
                _cached = try? decoder.decode([GeneralStation].self, from: data)
                return _cached ?? []
            }
        }
    }
    private var _cached: [GeneralStation]?
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private func checkThread() {
        assert(Thread.isMainThread)
    }
}

