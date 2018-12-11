//
//  MapViewModel.swift
//  NoBus
//
//  Created by Gao on 2018/12/10.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa
import fucking_beijing_bus_api

class MapViewModel {
    
    struct AllBusPositionInLine {
        let points: [CLLocationCoordinate2D]
        let belongToLine: LineDetail
    }
    
    // output
    struct Output {
        let status = BehaviorSubject<[AllBusPositionInLine]>(value: [])
        let staticLines = BehaviorSubject<[LineDetail]>(value:[])
        let center = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
        let referenceStation = BehaviorRelay<CLLocationCoordinate2D?>(value:nil)
    }
    let output = Output()
    
    // input
    let refreshTrigger = PublishSubject<Void>()
    
    init(lines:[LineDetail], referenceStation: LineDetail.Station?) {
        self.referenceStation = referenceStation
        self.lines = lines
        
        // static data
        output.staticLines.onNext(lines)
        let center: CLLocationCoordinate2D? = referenceStation.map { currentStation in
            currentStation.location.CLCoordinate2D
        }
        output.center.accept(center)
        output.referenceStation.accept(center)

        // reduce
        unowned let _self = self
        func getAllStatus() -> Observable<[(LineDetail, [BusStatusForStation])]> {
            let lines = _self.lines
            let requests
                = lines.map{  MapViewModel.getStatus(line: $0).asObservable() }
            return Observable.zip(requests)
        }
        
        refreshTrigger
            .flatMapLatest{ _ in getAllStatus() }
            .map {
                (status: [(LineDetail, [BusStatusForStation])]) -> [AllBusPositionInLine] in
                return status.map { info in
                    AllBusPositionInLine(
                        points: info.1.map{ $0.currentLocation.CLCoordinate2D },
                        belongToLine: info.0
                    )
                }
            }
            .bind(to: output.status)
            .disposed(by: bag)
        
        
        // automatically trigger
        Observable<Int>.interval(10, scheduler: MainScheduler.instance)
            .map{ _ in () }
            .bind(to: refreshTrigger)
            .disposed(by: bag)
        
        
    }
    
    
    private var lines: [LineDetail]
    private let referenceStation: LineDetail.Station?
    
    private let bag = DisposeBag()
    
    private static func getStatus(line:LineDetail) -> Single<(LineDetail, [BusStatusForStation])> {
        return Single.create { (completion) -> Disposable in
            BeijingBusAPI.RealTime.getAllBusesStatus(ofLine: line.ID, referenceStation: 0) { (result) in
                switch result {
                case .success(let v):
                    completion(SingleEvent.success((line,v)))
                case .failure(let e):
                    completion(SingleEvent.error(e))
                }
            }
            return Disposables.create()
        }
    }
}
