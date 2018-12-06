//
//  MainListViewModel.swift
//  NoBus
//
//  Created by Gao on 2018/10/28.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire


class MainListViewModel {
    
    public let items = Variable<[ItemViewModel.Section]>([])
    
    public let refreshButtonViewModel = RefreshButtonViewModel()
    
    func refreshData() {
        refreshTrigger.onNext(1)
    }
        
        
    init() {
        Observable.merge(
            // merge multiple triggers
            StationsManager.shared.allStations.asObserver().anyObservable(),
            refreshTrigger.asObserver().anyObservable(),
            refreshButtonViewModel.output.reloadAction.anyObservable(),
            Observable.just(0 as AnyObject) // the initial trigger
            )
            .map { _ in try StationsManager.shared.allStations.value() }
            
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
                    return ItemViewModel.StationCell.Line(lineNumber: lineStaion.belongedToLine.busNumber, status: status)
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
    
    private let interval: TimeInterval = 5
    
    init() {
        input.isReloading
            .debounce(0.5, scheduler: MainScheduler.asyncInstance)
            .bind(to: output.isReloading).disposed(by: bag)
        input.isReloading
            .map{ !$0 }
            .bind(to: output.isEnabled).disposed(by: bag)
        
        
        func oneLoop() {
            let delay = Observable.just(()).delay(interval, scheduler: MainScheduler.asyncInstance)
            let load = self.loadFinishedSignal()
            
            print("start a new loop for refresh")
            output.showNextTriggerCounterAnimation.onNext(interval)
            
            Observable.merge(
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
            .disposed(by: bag)
        }
        
        oneLoop()
    }
    
    private func loadFinishedSignal() -> Observable<Void> {
        return input.isReloading.asObserver()
            .filter { $0 == false }
            .map{ _ in () }
            .take(1)
    }
    
    private let bag = DisposeBag()
}
