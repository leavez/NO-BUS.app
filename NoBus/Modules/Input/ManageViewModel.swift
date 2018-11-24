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
    struct Input {
        
    }
    let output = Output()
    let input = Input()
    
    init() {
        StationsManager.shared.allStations
            .map {
                Array($0.map{ $0.stationsInLines }.joined())
            }
            .subscribeOn(MainScheduler.asyncInstance)
            .bind(to: output.items)
            .disposed(by: bag)
    }
    
    private let bag = DisposeBag()
}
