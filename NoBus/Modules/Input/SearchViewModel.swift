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
            .map {
                SearchViewModel.splitKeyword($0)
            }
            .do(onNext: { (name, line) in
                print("keyword: \(String(describing: name)), \(String(describing: line))")
            })
            .flatMapLatest { (name, line) in
                // todo split the keyword
                StationSearchManager.shared.search(fuzzyStationName: name, lineNumber: line)
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
    
    private static func splitKeyword(_ s: String?) -> (name:String?, line:String?) {
        guard let s = s else {
            return (nil, nil)
        }
        
        let lineRegex = try! NSRegularExpression(pattern: "[0-9]+", options: [])
        let stationName = try! NSRegularExpression(pattern: "[^0-9^ ]+", options: [])
        let len = s.count
        let line: String? = lineRegex.firstMatch(in: s, range: NSMakeRange(0, len)).map {
            let range = $0.range
            return (s as NSString).substring(with: range)
        }
        let name: String? = stationName.firstMatch(in: s, range: NSMakeRange(0, len)).map {
            let range = $0.range
            return (s as NSString).substring(with: range)
        }
        return (name, line)
    }
}
