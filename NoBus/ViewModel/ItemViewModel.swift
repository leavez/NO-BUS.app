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
                    "\(status.distanceRemain)\u{2009}米"
                    }())
                timeRemain.onNext({
                    let s = Date(timeIntervalSince1970: status.estimatedArrivedTime)
                        .readableDescriptionToNow
                    return "预计\u{2009}\(s)"
                    }())
                updatedTime.onNext({
                    let s = Date(timeIntervalSince1970: status.gpsUpdatedTime)
                        .readableDescriptionToNow
                    return "\(s)\u{2009}前更新"
                    }())
            }
        }
        
        let name: String
        let lines = BehaviorSubject<[Line]>(value: [])
        
        init(stationName:String, lines:[Line]) {
            name = stationName
            self.lines.onNext(lines)
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
