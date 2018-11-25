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
        let showHint = BehaviorSubject<Bool>(value: false)
        let hint = BehaviorSubject<String>(value: "")
        let showLoadingIndiciator = BehaviorSubject<Bool>(value: false)
    }
    
    let input = Input()
    let output = Output()
    
    init() {
        let keywordChanged = input.keyword.map {
            SearchViewModel.splitKeyword($0)
            }
            .do(onNext: { (name, line) in
                print("keyword: \(String(describing: name)), \(String(describing: line))")
            })
            .share()
        
        let searchResult = keywordChanged
            .flatMapLatest { (name, line) in
                // todo split the keyword
                StationSearchManager.shared.search(fuzzyStationName: name, lineNumber: line)
            }
            .observeOn(MainScheduler.asyncInstance)
            .share()

        // items
        searchResult.map {
                $0 ?? []
            }
            .bind(to: output.items)
            .disposed(by: bag)
        

        // hint
        enum SearchResult {
            case items([Station])
            case noResult
            case waitForMoreInput
        }
        
        let typedResult = searchResult.map { result -> SearchResult in
            if let result = result {
                if result.isEmpty {
                    return .waitForMoreInput
                } else {
                    return .items(result)
                }
            } else {
                return .noResult
            }
        }
        /// 这里的功能稍微复杂：
        ///
        /// - 如果搜索结果没有找到，则直接显示
        /// - 如果是没有输入，则显示空字符串
        /// - 如果是等待输入更多：
        ///    - 延迟一秒后才提示
        ///    - 根据是否输入公交路线，提示不同内容
        Observable.combineLatest(typedResult, keywordChanged)
            .flatMapLatest { result, keyword -> Observable<String> in
            switch result {
            case .items(_):
                return Observable.just("")
            case .noResult:
                return Observable.just("没有找到")
            case .waitForMoreInput:
                let (name, line) = keyword
                if name == nil && line == nil {
                    return Observable.just("")
                } else {
                    var text = "请输入更多"
                    if line == nil {
                        text += "\n(公交路线是必要的)"
                    }
                    return Observable.just(text).delay(1, scheduler: MainScheduler.instance)
                }
            }
            }
            .distinctUntilChanged()
            .bind(to: output.hint)
            .disposed(by: bag)
        
        output.items.share()
            .map { $0.count == 0 }
            .bind(to: output.showHint).disposed(by: bag)

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
