//
//  DisplayModel.swift
//  NoBus
//
//  Created by Gao on 2018/11/12.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift

/// view model for tableview cell
struct ItemViewModel {
    
    /// represent a cell
    struct StationCell {
        
        struct Line {
            
            let title = BehaviorSubject(value: "")
            let distanceRemain = BehaviorSubject(value: "")
            let timeRemain = BehaviorSubject(value: "")
            let updatedTime = BehaviorSubject(value: "")
            
            init(lineNumber:String, status:BusStatusForStation) {
                title.onNext(lineNumber)
                distanceRemain.onNext({
                    if status.distanceRemain > 1000 {
                        return String(format: "%0.1f\u{2009}千米", Double(status.distanceRemain)/1000.0)
                    } else {
                        return "\(status.distanceRemain)\u{2009}米"
                    }
                    }())
                timeRemain.onNext({
                    let s = Date(timeIntervalSince1970: status.estimatedArrivedTime)
                        .furtureDurationDescription
                    return "预计\u{2009}\(s)"
                    }())
                updatedTime.onNext({
                    let s = Date(timeIntervalSince1970: status.gpsUpdatedTime)
                        .pastDurationDescription
                    return "\(s)前更新"
                    }())
            }
            
            init() {}
        }
        
        let name: String
        let lines: BehaviorSubject<[Line]>
        
        init(stationName:String, lines:[Line]) {
            name = stationName
            if lines.count > 0 {
                self.lines = BehaviorSubject(value: lines)
            } else {
                let placeholder = Line()
                placeholder.updatedTime.onNext("暂无数据")
                self.lines = BehaviorSubject(value: [placeholder])
            }
        }
        
    }
    
    struct Section {
        
        typealias Item = ItemViewModel.StationCell
        var title: String = ""
        var stations: [Item] = []
    }
}


extension ItemViewModel.Section: SectionModelType {
    var items: [Item] {
        return self.stations
    }
    init(original: ItemViewModel.Section, items: [Item]) {
        self.init()
        self.title = original.title
        self.stations = items
    }
}
