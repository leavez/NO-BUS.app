//
//  MainListViewModel.swift
//  NoBus
//
//  Created by Gao on 2018/10/28.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Alamofire
import CoreLocation


class MainListViewModel {
    
    public let items = Variable<[ItemViewModel.Section]>([])
    
    public let refreshButtonViewModel = RefreshButtonViewModel()
    
    func refreshData() {
        refreshTrigger.onNext(1)
    }
        
        
    init() {
        let triggers = Observable.merge(
            refreshTrigger.asObserver().anyObservable(),
            refreshButtonViewModel.output.reloadAction.anyObservable(),
            Observable.just(0 as AnyObject) // the initial trigger
        ).debug("triggers")
        
        Observable.combineLatest(
                self.sortedStations,
                triggers
            )
            .map { return $0.0 }
            
            // get the real time data, and bind it to output"
            .do(onNext: {[unowned self] (_) in
                self.refreshButtonViewModel.input.isReloading.onNext(true)
            })
            .flatMapLatest({ [unowned self] in
                self.loadData(stations: $0)
            })
            .do(onNext: {[unowned self] (_) in
                self.refreshButtonViewModel.input.isReloading.onNext(false)
            })
            .map(render)
            .catchErrorJustReturn([])
            .bind(to: items)
            .disposed(by: bag)
    }

    private let refreshTrigger = PublishSubject<Int>()
    
    func render(data: (stations:[GeneralStation], map:[String:BusStatusForStation]))
        -> [ItemViewModel.Section] {
            
            var group = ItemViewModel.Section()
            
            group.stations = data.stations.map({ (generalStation:GeneralStation) ->
                ItemViewModel.StationCell in
                
                let lines = generalStation.stationsInLines.compactMap({
                    (lineStaion:Station) -> ItemViewModel.StationCell.Line? in
                    
                    let id = lineStaion.belongedToLine.ID
                    guard let status = data.map[id] else {
                        return nil
                    }
                    // transfrom status to visiable texts
                    return ItemViewModel.StationCell.Line(line: lineStaion.belongedToLine, status: status)
                })
                
                let s = ItemViewModel.StationCell(stationName: generalStation.name, lines: lines)
                return s
            })
            return [group]
    }
    
    func loadData(stations: [GeneralStation]) -> Observable<(stations:[GeneralStation], map:[String:BusStatusForStation])> {
        
        
        return Observable.create { (observer) -> Disposable in
            
            let s = stations.flatMap {
                $0.stationsInLines
            }
            
            DataFetcher.getStatus(for: s) {
                (result: Result<[String:BusStatusForStation]>) -> () in
                switch result {
                case .success(let v):
                    observer.onNext((stations, v))
                    observer.onCompleted()
                case .failure(let e):
                    observer.onError(e)
                }
            }
            
            return Disposables.create()
        }
    }
    
    private let bag = DisposeBag()
    
    
    // MARK:- sorted stations by distance
    
    private let sortedStations:
        Observable<[GeneralStation]> = {
        
        func sorting(_ array: [GeneralStation], _ location: CLLocation?) -> [GeneralStation] {
            guard let location = location else {
                return array
            }
            return array.sorted(by: { (one, another) -> Bool in
                guard let s1 = one.stationsInLines.first else { return false }
                guard let s2 = another.stationsInLines.first else { return true }
                let distances = [s1, s2].map { (s: Station) -> CLLocationDistance in
                    let c = s.apiObject.location
                    let cl = CLLocation(latitude: c.latitude, longitude: c.longitude)
                    return location.distance(from: cl)
                }
                return distances[0] < distances[1]
            })
        }
        
        /// return location within 0.5s or emit a nil then a location.
        let nonDelayedLocation: Observable<CLLocation?> = {
            return Observable.merge(
                LocationManager.shared.location.take(1).debug("location"),
                Observable<CLLocation?>.just(nil).delay(0.5, scheduler: MainScheduler.instance)
                ).scan([nil,nil], accumulator: { (sum: [CLLocation?], current: CLLocation?) in
                    return [sum[1], current]
                })
                .takeWhile {
                    $0[0] == nil
                }.map { $0[1] }
        }()
        
        /// Return stations sorted by distance to current location
        /// (There will only one locating action)
        return nonDelayedLocation.flatMapLatest { location in
            return StationsManager.shared.allStations.map {
                sorting($0, location)
            }
        }
    }()
    
}



public class RefreshButtonViewModel {
    
    struct Input {
        let manualTrigger = PublishSubject<Void>()
        fileprivate let isReloading = BehaviorSubject(value: false)
    }
    struct Output {
        fileprivate let reloadAction = PublishSubject<Void>()
        let showNextTriggerCounterAnimation = PublishSubject<TimeInterval>()
        let isReloading = BehaviorSubject(value: false)
        let isEnabled = BehaviorSubject(value: true)
    }
    
    let input = Input()
    let output = Output()
    
    private let interval: TimeInterval = 10
    
    init() {
        
        input.isReloading
            // add a grace time
            .flatMapLatest({ reloading -> Observable<Bool> in
                if !reloading {
                    return Observable.just(false)
                }
                return Observable.just(true).delay(0.3, scheduler: MainScheduler.instance)
            })
            .bind(to: output.isReloading).disposed(by: bag)
        
        input.isReloading
            .map{ !$0 }
            .bind(to: output.isEnabled).disposed(by: bag)
        
        // polling
        func oneLoop() {
            let delay = Observable.just(()).delay(interval, scheduler: MainScheduler.asyncInstance)
            let load = self.loadFinishedSignal()
            
            print("start a new loop for refresh")
            output.showNextTriggerCounterAnimation.onNext(interval)
            
            self.loopDispoable?.dispose()
            self.loopDispoable = Observable.merge(
                delay,
                input.manualTrigger
            )
            .take(1)
            .do(onCompleted: { [unowned self] in
                print("should do a refresh")
                self.output.reloadAction.onNext(())
            })
            .concat(load)
            .subscribe(onCompleted: {
                oneLoop()
            })
            self.loopDispoable?.disposed(by: bag)
        }
        
        oneLoop()
        
        // trigger when enter foreground
        NotificationCenter.default.rx
            .notification(UIApplication.willEnterForegroundNotification)
            .subscribe(onNext: {[weak self] _ in
                oneLoop()
                self?.input.manualTrigger.onNext(())
            }).disposed(by: bag)
        
        // stop when enter background
        NotificationCenter.default.rx
            .notification(UIApplication.didEnterBackgroundNotification)
            .subscribe(onNext: {[weak self] _ in
                self?.loopDispoable?.dispose()
            }).disposed(by: bag)
        
    }
    
    private func loadFinishedSignal() -> Observable<Void> {
        return input.isReloading.asObserver()
            .filter { $0 == false }
            .map{ _ in () }
            .take(1)
    }
    
    private let bag = DisposeBag()
    private var loopDispoable: Disposable?
}
