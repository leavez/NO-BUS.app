//
//  InputViewModel.swift
//  NoBus
//
//  Created by Gao on 2018/11/14.
//  Copyright © 2018 me.leavez. All rights reserved.
//


import Foundation
import RxSwift
import RxCocoa

struct ManageViewModel {
    
    struct Output {
        let items = BehaviorSubject<[Station]>(value: [])
    }
    
    let output = Output()
    
    init() {
        StationsManager.shared.allStations
            .map {
                Array($0.map{ $0.stationsInLines }.joined())
            }
            .subscribeOn(MainScheduler.asyncInstance)
            .bind(to: output.items)
            .disposed(by: bag)
    }
    
    func didTapRemoveStation(station: Station) {
        StationsManager.shared.removeFromSaved(station: station)
    }
    
    
    
    private let bag = DisposeBag()
}
