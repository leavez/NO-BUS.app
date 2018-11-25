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
    
    func refreshData() {
        refreshTrigger.onNext(1)
    }
        
        
    init() {
        Observable.combineLatest(
            StationsManager.shared.allStations.asObserver(),
            refreshTrigger.asObserver()
            )
            .map { $0.0 }
            .flatMapLatest({ [unowned self] in
                self.loadData(stations: $0)
            })
            .map(render)
            .catchErrorJustReturn([])
            .bind(to: items)
            .disposed(by: bag)
        
        // As refreshTrigger is a publish subject, which have no intial value
        // so the combineLatest will wait until the first value sent
        refreshTrigger.onNext(1)
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


