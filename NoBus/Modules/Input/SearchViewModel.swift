//
//  SearchViewModel.swift
//  NoBus
//
//  Created by Gao on 2018/11/14.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import RxSwift

struct SearchViewModel {
    
    struct Input {
        let keyword = PublishSubject<String?>()
    }
    struct Output {
        let items = BehaviorSubject<[Station]>(value: [])
        let showNoResultHint = BehaviorSubject<Bool>(value: false)
    }
    
    let input = Input()
    let output = Output()
    
    init() {
        let searchResult = input.keyword.asObserver()
            .do(onNext: { (s) in
                print("keyword: \(String(describing: s))")
            })
            .flatMapLatest {
                // todo split the keyword
                StationSearchManager.shared.search(fuzzyStationName: nil, lineNumber: $0)
            }
            .observeOn(MainScheduler.asyncInstance)
            .share()
            
        searchResult.map {
                $0 ?? []
            }
            .bind(to: output.items)
            .disposed(by: bag)
        
        searchResult.map {
                $0 == nil
            }.bind(to: output.showNoResultHint)
            .disposed(by: bag)
    }

    private let bag = DisposeBag()
}
