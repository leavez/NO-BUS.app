//
//  MainListViewModel.swift
//  NoBus
//
//  Created by Gao on 2018/10/28.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import Alamofire


struct DisplayModel {
    
    final class Line {
        var name = ""
        var distanceRemain: Int = 0
    }
    
    final class Station {
        var name: String = ""
        var lines: [DisplayModel.Line] = []
    }
    
    final class Group: SectionModelType {
        
        
        typealias Item = DisplayModel.Station
        var title: String = ""
        var stations: [Item] = []
        
        // --- SectionModelType ---
        var items: [Item] {
            return self.stations
        }
        required convenience init(original: DisplayModel.Group, items: [Item]) {
            self.init()
            self.title = original.title
            self.stations = items
        }
    }
}


extension DisplayModel.Line: Codable {}
extension DisplayModel.Station: Codable {}
extension DisplayModel.Group: Codable {}




class MainListViewModel {
    
    let items = Variable<[DisplayModel.Group]>([])
    private let bag = DisposeBag()
    
    init() {
        loadData()
            .map(render)
            .bind(to: items)
            .disposed(by: bag)
    }
    
    
    func render(data: (spots:[Spot], map:[String:BusStatusForStation]))
        -> [DisplayModel.Group] {

        return data.spots.map { (spot) -> DisplayModel.Group in
            
            let group = DisplayModel.Group()
            group.stations = spot.stations.map({ (generalStation:GeneralStation) ->
                DisplayModel.Station in
                
                let s = DisplayModel.Station()
                s.name = generalStation.name
                s.lines = generalStation.stationsInLines.compactMap({
                    (lineStaion:Station) -> DisplayModel.Line? in
                    
                    let id = lineStaion.belongedToLine.ID
                    guard let status = data.map[id] else {
                        return nil
                    }
                    // transfrom status to visiable texts
                    let line = DisplayModel.Line()
                    line.name = lineStaion.belongedToLine.busNumber
                    line.distanceRemain = status.distanceRemain
                    return line
                })
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
    
    
//            var text = ""
//            if let statusMap = result.value {
//                text += statusMap.map({ (id, status) -> String in
//                    let name = id
//                    let d = status.distanceRemain
//                    let t = status.estimatedRunDuration
//                    let updated = Date(timeIntervalSince1970:  status.gpsUpdatedTime)
//                    return String(format: "%@: %dm %.2fmins, %@", name, d, t/60, "\(updated)")
//
//                }).joined(separator: "\n")
//            }
//            text += "\n\n"
//            text += "\n\(result.debugDescription)"
//        textView.text = "loading"
    
}


