//
//  LocateManger.swift
//  NoBus
//
//  Created by Gao on 2018/12/8.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa
import RxCoreLocation
import ChinaShift

class LocationManager {
    
    static let shared = LocationManager()
    
    var location: Observable<CLLocation?> {
        return _location
    }
    
    private init() {
        manager.requestWhenInUseAuthorization()
        _location = manager.rx.didChangeAuthorization
            .filter {
                $0.status == .authorizedWhenInUse ||
                $0.status == .authorizedAlways
            }.flatMap { (manager, _) in
                manager.rx.location
            }
            .map({ (l) -> CLLocation? in
                guard let c = l?.coordinate else { return l }
                let new = transformFromWGSToGCJ(Location(lng: c.longitude, lat: c.latitude))
                return CLLocation(latitude: new.lat, longitude: new.lng)
            })
            .replayAll()
        
        _location.connect()
            .disposed(by: bag)
    }
    
    private let manager = CLLocationManager()
    private let _location: ConnectableObservable<CLLocation?>
    private let bag = DisposeBag()
}

