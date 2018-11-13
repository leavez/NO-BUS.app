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
    
    init() {
        loadData()
            .map(render)
            .catchErrorJustReturn([])
            .bind(to: items)
            .disposed(by: bag)
    }
    
    
    func render(data: (spots:[Spot], map:[String:BusStatusForStation]))
        -> [ItemViewModel.Section] {

        return data.spots.map { (spot) -> ItemViewModel.Section in
            
            var group = ItemViewModel.Section()
            group.stations = spot.stations.map({ (generalStation:GeneralStation) ->
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
            return group
        }
    }
    
    func loadData() -> Observable<(spots:[Spot], map:[String:BusStatusForStation])> {
        
        return Observable.create { (observer) -> Disposable in
            
            SpotsManager.shared.getAllSpot { (spots) in
                DataFetcher.getStatus(for: spots) {
                    (result: Result<[String:BusStatusForStation]>) -> () in
                    switch result {
                    case .success(let v):
                        observer.onNext((spots, v))
                        observer.onCompleted()
                    case .failure(let e):
                        observer.onError(e)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    private let bag = DisposeBag()

}


