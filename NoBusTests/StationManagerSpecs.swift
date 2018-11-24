//
//  StationManagerSpecs.swift
//  NoBusTests
//
//  Created by leave on 2018/11/15.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
@testable import NoBus

class StationManagerSpecs: QuickSpec {
    override func spec() {
        
        //        let a = XCTestExpectation(description: "a")
        //        _ = self.getAStation("地铁五道口站", "126").subscribe(onNext:{
        //            for s in $0 {
        //                print(try! JSONEncoder().encode(s).base64EncodedString())
        //            }
        //        })
        //        wait(for: [a],timeout:10)
        
        describe("station manager") {
            context("when initialized") {
                
                let manager = StationsManager.shared
                StationsManager.shared.removeAll()
                
                it("should have no content") {
                    expect(manager.allSavedStationsAndLines()).to(beEmpty())
                }
                it("should save the result") {
                    manager.addToSaved(station: self.getAStation_wudaokou_398())
                    expect(manager.allSavedStationsAndLines().first?
                        .name).to(equal("地铁五道口站"))
                    expect(manager.allSavedStationsAndLines().first?
                        .stationsInLines.first?.belongedToLine.busNumber)
                        .to(equal("398"))
                }
                it ("should combine the same station name") {
                    manager.removeAll()
                    manager.addToSaved(station: self.getAStation_wudaokou_398())
                    manager.addToSaved(station: self.getAStation_wudaokou_126())
                    expect(manager.allSavedStationsAndLines().count) == 1
                    expect(manager.allSavedStationsAndLines().first?.stationsInLines.count) == 2
                }
                it ("shouldn't add line twice") {
                    manager.removeAll()
                    manager.addToSaved(station: self.getAStation_wudaokou_398())
                    manager.addToSaved(station: self.getAStation_wudaokou_398())
                    expect(manager.allSavedStationsAndLines().count) == 1
                    expect(manager.allSavedStationsAndLines().first?.stationsInLines.count) == 1
                }
                it ("should add new station") {
                    manager.removeAll()
                    manager.addToSaved(station: self.getAStation_wudaokou_398())
                    manager.addToSaved(station: self.getAStation_wudaokou_126())
                    manager.addToSaved(station: self.getAStation_东内小街_106())
                    manager.addToSaved(station: self.getAStation_beiyu_398())
                    expect(manager.allSavedStationsAndLines().count) == 3
                }
                
                it ("should can delete a station") {
                    manager.removeAll()
                    manager.addToSaved(station: self.getAStation_wudaokou_398())
                    manager.addToSaved(station: self.getAStation_wudaokou_126())
                    manager.addToSaved(station: self.getAStation_东内小街_106())
                    manager.addToSaved(station: self.getAStation_beiyu_398())
                    manager.removeFromSaved(station: self.getAStation_东内小街_106())
                    
                    expect(manager.allSavedStationsAndLines().first(where: { (s) -> Bool in
                        s.name == "东内小街"
                    })).to(beNil())
                    expect(manager.allSavedStationsAndLines().first(where: { (s) -> Bool in
                        s.name == "地铁五道口站"
                    })).toNot(beNil())
                    
                    manager.removeFromSaved(station: self.getAStation_wudaokou_126())
                    expect(manager.allSavedStationsAndLines().filter({ (s) -> Bool in
                        s.name == "地铁五道口站"
                    }).count).to(equal(1))
                    manager.removeFromSaved(station: self.getAStation_wudaokou_398())
                    expect(manager.allSavedStationsAndLines().first(where: { (s) -> Bool in
                        s.name == "地铁五道口站"
                    })).to(beNil())
                }
            }
            
        }
    }
    
    func getAStation(_ name: String, _ line: String) -> Observable<[Station]> {
        let search = StationSearchManager.shared.search(fuzzyStationName: name, lineNumber: line)
        return search.map {
            if let stations = $0, stations.count > 0 {
                return stations
            } else {
                XCTFail("no result")
                fatalError()
            }
        }
    }
    
    func getAStation_beiyu_398() -> Station {
        let data = "eyJiZWxvbmdlZFRvTGluZSI6eyJidXNOdW1iZXIiOiIzOTgiLCJvcGVyYXRpb25UaW1lIjoiNToyMC0yMjoxMCIsImNvb3JkcyI6IjExNi4zNDMzNSw0MC4wNTU0NiwxMTYuMzQyODcsNDAuMDU5NzQsMTE2LjMzMzI3LDQwLjA1Nzk2LDExNi4zMzI4MSw0MC4wNTc4MiwxMTYuMzMyMzcsNDAuMDU3NjEsMTE2LjMyODgsNDAuMDU0OTQsMTE2LjMyOTY2LDQwLjA1Mzc4LDExNi4zMjk5Nyw0MC4wNTMwMSwxMTYuMzM5NzEsNDAuMDQwMjgsMTE2LjM0MDQxLDQwLjAzOTU3LDExNi4zNDA5Myw0MC4wMzg5MywxMTYuMzQxMTEsNDAuMDM4NjgsMTE2LjM0MTU2LDQwLjAzODE5LDExNi4zNDI5OSw0MC4wMzY1LDExNi4zNDQ3Niw0MC4wMzM3OCwxMTYuMzQ1MDQsNDAuMDMzNDksMTE2LjM0NTU4LDQwLjAzMzA3LDExNi4zNDY5OCw0MC4wMzEzOCwxMTYuMzQ5ODYsNDAuMDI3NjgsMTE2LjM1MDUsNDAuMDI2NzYsMTE2LjM1MDUyLDQwLjAyNjc0LDExNi4zNTE0MSw0MC4wMjU1MywxMTYuMzUxNDgsNDAuMDI1MzksMTE2LjM1MTUsNDAuMDI1MzEsMTE2LjM1MTUxLDQwLjAyNSwxMTYuMzUxNDQsNDAuMDI0NTQsMTE2LjM1MTI4LDQwLjAyNDE5LDExNi4zNTExNSw0MC4wMjQwMiwxMTYuMzUwODgsNDAuMDIzNzQsMTE2LjM1MDg1LDQwLjAyMzY5LDExNi4zNTA4LDQwLjAyMzU1LDExNi4zNTA3OCw0MC4wMjMzOCwxMTYuMzUwNzksNDAuMDIzMTQsMTE2LjM1MDgxLDQwLjAyMzAzLDExNi4zNTA4Miw0MC4wMjMwMSwxMTYuMzUwODYsNDAuMDIyODcsMTE2LjM1MDk0LDQwLjAyMjcxLDExNi4zNTEwOCw0MC4wMjI1OCwxMTYuMzUxNTMsNDAuMDIyMzQsMTE2LjM1MTYsNDAuMDIyMjksMTE2LjM1MTY1LDQwLjAyMjIzLDExNi4zNTE2Nyw0MC4wMjIxOCwxMTYuMzUyNDEsNDAuMDA4NjYsMTE2LjM1MjM2LDQwLjAwNzk4LDExNi4zNTIzMSw0MC4wMDc2NCwxMTYuMzUzMDIsMzkuOTkzNCwxMTYuMzQ4MjksMzkuOTkzMjYsMTE2LjM0ODE5LDM5Ljk5MzI1LDExNi4zMzg3OSwzOS45OTMsMTE2LjMzODQ0LDM5Ljk5Mjk4LDExNi4zMzgwOSwzOS45OTI5OCwxMTYuMzM4MDMsMzkuOTkyOTcsMTE2LjMzNjkzLDM5Ljk5Mjk1LDExNi4zMzY5MSwzOS45OTI4NSwxMTYuMzM3NTksMzkuOTg5ODcsMTE2LjMzNzY2NywzOS45ODg4ODQiLCJzdGF0aW9ucyI6W3sibmFtZSI6IuiCsuaWsOWwj+WMuiIsImluZGV4IjoxLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zNDMyNDMsImxhdGl0dWRlIjo0MC4wNTYxMTkwMDAwMDAwMDJ9fSx7Im5hbWUiOiLogrLmlrDlsI/ljLrljJflj6MiLCJpbmRleCI6MiwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzQxNzgxLCJsYXRpdHVkZSI6NDAuMDU5NTQ1OTk5OTk5OTk3fX0seyJuYW1lIjoi6YKu5pS/56CU56m26ZmiIiwiaW5kZXgiOjMsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjMzNjA5MSwibGF0aXR1ZGUiOjQwLjA1ODQ4NDk5OTk5OTk5N319LHsibmFtZSI6Iuilv+S4ieaXl+ahpeS4nCIsImluZGV4Ijo0LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zMzA3NDcsImxhdGl0dWRlIjo0MC4wNTYzODQwMDAwMDAwMDF9fSx7Im5hbWUiOiLmuIXmsrPlsI/okKXmoaXljZciLCJpbmRleCI6NSwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzQyNDcxLCJsYXRpdHVkZSI6NDAuMDM3MTAxOTk5OTk5OTk3fX0seyJuYW1lIjoi5riF5rKzIiwiaW5kZXgiOjYsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjM0NzgzNiwibGF0aXR1ZGUiOjQwLjAzMDMxNjk5OTk5OTk5N319LHsibmFtZSI6IumprOWutuaynyIsImluZGV4Ijo3LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zNTE4NzMsImxhdGl0dWRlIjo0MC4wMTc4NzAwMDAwMDAwMDJ9fSx7Im5hbWUiOiLlrabnn6Xlm60iLCJpbmRleCI6OCwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzUyMDgyOTk5OTk5OTksImxhdGl0dWRlIjo0MC4wMTQ3MTg5OTk5OTk5OTl9fSx7Im5hbWUiOiLnn7Pmnb/miL8iLCJpbmRleCI6OSwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzUyMzExLCJsYXRpdHVkZSI6NDAuMDA2NzAwMDAwMDAwMDAyfX0seyJuYW1lIjoi6Z2Z5reR6IuRIiwiaW5kZXgiOjEwLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zNTI0NSwibGF0aXR1ZGUiOjQwLjAwNDE1MDAwMDAwMDAwM319LHsibmFtZSI6IuWtpumZoui3r+WMl+WPoyIsImluZGV4IjoxMSwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzUyODE4LCJsYXRpdHVkZSI6MzkuOTk3MDl9fSx7Im5hbWUiOiLljJfkuqzor63oqIDlpKflraYiLCJpbmRleCI6MTIsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjM0NTIyLCJsYXRpdHVkZSI6MzkuOTkzMTYxOTk5OTk5OTk4fX0seyJuYW1lIjoi5Zyw6ZOB5LqU6YGT5Y+j56uZIiwiaW5kZXgiOjEzLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zMzg4NCwibGF0aXR1ZGUiOjM5Ljk5MzAwMDAwMDAwMDAwMn19LHsibmFtZSI6IuS6lOmBk+WPo+WFrOS6pOWcuuermSIsImluZGV4IjoxNCwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzM3Njc2LCJsYXRpdHVkZSI6MzkuOTg4NzU5OTk5OTk5OTk5fX1dLCJ0ZXJtaW5hbFN0YXRpb25OYW1lIjoi5LqU6YGT5Y+j5YWs5Lqk5Zy656uZIiwiSUQiOiIxMzQ3IiwiZGVwYXJ0dXJlU3RhdGlvbk5hbWUiOiLogrLmlrDlsI/ljLoifSwibmV4dFN0YXRpb24iOnsibmFtZSI6IuWcsOmTgeS6lOmBk+WPo+ermSIsImluZGV4IjoxMywibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzM4ODQsImxhdGl0dWRlIjozOS45OTMwMDAwMDAwMDAwMDJ9fSwiYXBpT2JqZWN0Ijp7Im5hbWUiOiLljJfkuqzor63oqIDlpKflraYiLCJpbmRleCI6MTIsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjM0NTIyLCJsYXRpdHVkZSI6MzkuOTkzMTYxOTk5OTk5OTk4fX19"
        let s = getStationFrom(base64Data: data)
        return s
    }
    
    func getAStation_wudaokou_398() -> Station {
        let data = "eyJiZWxvbmdlZFRvTGluZSI6eyJidXNOdW1iZXIiOiIzOTgiLCJvcGVyYXRpb25UaW1lIjoiNToyMC0yMjoxMCIsImNvb3JkcyI6IjExNi4zNDMzNSw0MC4wNTU0NiwxMTYuMzQyODcsNDAuMDU5NzQsMTE2LjMzMzI3LDQwLjA1Nzk2LDExNi4zMzI4MSw0MC4wNTc4MiwxMTYuMzMyMzcsNDAuMDU3NjEsMTE2LjMyODgsNDAuMDU0OTQsMTE2LjMyOTY2LDQwLjA1Mzc4LDExNi4zMjk5Nyw0MC4wNTMwMSwxMTYuMzM5NzEsNDAuMDQwMjgsMTE2LjM0MDQxLDQwLjAzOTU3LDExNi4zNDA5Myw0MC4wMzg5MywxMTYuMzQxMTEsNDAuMDM4NjgsMTE2LjM0MTU2LDQwLjAzODE5LDExNi4zNDI5OSw0MC4wMzY1LDExNi4zNDQ3Niw0MC4wMzM3OCwxMTYuMzQ1MDQsNDAuMDMzNDksMTE2LjM0NTU4LDQwLjAzMzA3LDExNi4zNDY5OCw0MC4wMzEzOCwxMTYuMzQ5ODYsNDAuMDI3NjgsMTE2LjM1MDUsNDAuMDI2NzYsMTE2LjM1MDUyLDQwLjAyNjc0LDExNi4zNTE0MSw0MC4wMjU1MywxMTYuMzUxNDgsNDAuMDI1MzksMTE2LjM1MTUsNDAuMDI1MzEsMTE2LjM1MTUxLDQwLjAyNSwxMTYuMzUxNDQsNDAuMDI0NTQsMTE2LjM1MTI4LDQwLjAyNDE5LDExNi4zNTExNSw0MC4wMjQwMiwxMTYuMzUwODgsNDAuMDIzNzQsMTE2LjM1MDg1LDQwLjAyMzY5LDExNi4zNTA4LDQwLjAyMzU1LDExNi4zNTA3OCw0MC4wMjMzOCwxMTYuMzUwNzksNDAuMDIzMTQsMTE2LjM1MDgxLDQwLjAyMzAzLDExNi4zNTA4Miw0MC4wMjMwMSwxMTYuMzUwODYsNDAuMDIyODcsMTE2LjM1MDk0LDQwLjAyMjcxLDExNi4zNTEwOCw0MC4wMjI1OCwxMTYuMzUxNTMsNDAuMDIyMzQsMTE2LjM1MTYsNDAuMDIyMjksMTE2LjM1MTY1LDQwLjAyMjIzLDExNi4zNTE2Nyw0MC4wMjIxOCwxMTYuMzUyNDEsNDAuMDA4NjYsMTE2LjM1MjM2LDQwLjAwNzk4LDExNi4zNTIzMSw0MC4wMDc2NCwxMTYuMzUzMDIsMzkuOTkzNCwxMTYuMzQ4MjksMzkuOTkzMjYsMTE2LjM0ODE5LDM5Ljk5MzI1LDExNi4zMzg3OSwzOS45OTMsMTE2LjMzODQ0LDM5Ljk5Mjk4LDExNi4zMzgwOSwzOS45OTI5OCwxMTYuMzM4MDMsMzkuOTkyOTcsMTE2LjMzNjkzLDM5Ljk5Mjk1LDExNi4zMzY5MSwzOS45OTI4NSwxMTYuMzM3NTksMzkuOTg5ODcsMTE2LjMzNzY2NywzOS45ODg4ODQiLCJzdGF0aW9ucyI6W3sibmFtZSI6IuiCsuaWsOWwj+WMuiIsImluZGV4IjoxLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zNDMyNDMsImxhdGl0dWRlIjo0MC4wNTYxMTkwMDAwMDAwMDJ9fSx7Im5hbWUiOiLogrLmlrDlsI/ljLrljJflj6MiLCJpbmRleCI6MiwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzQxNzgxLCJsYXRpdHVkZSI6NDAuMDU5NTQ1OTk5OTk5OTk3fX0seyJuYW1lIjoi6YKu5pS/56CU56m26ZmiIiwiaW5kZXgiOjMsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjMzNjA5MSwibGF0aXR1ZGUiOjQwLjA1ODQ4NDk5OTk5OTk5N319LHsibmFtZSI6Iuilv+S4ieaXl+ahpeS4nCIsImluZGV4Ijo0LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zMzA3NDcsImxhdGl0dWRlIjo0MC4wNTYzODQwMDAwMDAwMDF9fSx7Im5hbWUiOiLmuIXmsrPlsI/okKXmoaXljZciLCJpbmRleCI6NSwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzQyNDcxLCJsYXRpdHVkZSI6NDAuMDM3MTAxOTk5OTk5OTk3fX0seyJuYW1lIjoi5riF5rKzIiwiaW5kZXgiOjYsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjM0NzgzNiwibGF0aXR1ZGUiOjQwLjAzMDMxNjk5OTk5OTk5N319LHsibmFtZSI6IumprOWutuaynyIsImluZGV4Ijo3LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zNTE4NzMsImxhdGl0dWRlIjo0MC4wMTc4NzAwMDAwMDAwMDJ9fSx7Im5hbWUiOiLlrabnn6Xlm60iLCJpbmRleCI6OCwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzUyMDgyOTk5OTk5OTksImxhdGl0dWRlIjo0MC4wMTQ3MTg5OTk5OTk5OTl9fSx7Im5hbWUiOiLnn7Pmnb/miL8iLCJpbmRleCI6OSwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzUyMzExLCJsYXRpdHVkZSI6NDAuMDA2NzAwMDAwMDAwMDAyfX0seyJuYW1lIjoi6Z2Z5reR6IuRIiwiaW5kZXgiOjEwLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zNTI0NSwibGF0aXR1ZGUiOjQwLjAwNDE1MDAwMDAwMDAwM319LHsibmFtZSI6IuWtpumZoui3r+WMl+WPoyIsImluZGV4IjoxMSwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzUyODE4LCJsYXRpdHVkZSI6MzkuOTk3MDl9fSx7Im5hbWUiOiLljJfkuqzor63oqIDlpKflraYiLCJpbmRleCI6MTIsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjM0NTIyLCJsYXRpdHVkZSI6MzkuOTkzMTYxOTk5OTk5OTk4fX0seyJuYW1lIjoi5Zyw6ZOB5LqU6YGT5Y+j56uZIiwiaW5kZXgiOjEzLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zMzg4NCwibGF0aXR1ZGUiOjM5Ljk5MzAwMDAwMDAwMDAwMn19LHsibmFtZSI6IuS6lOmBk+WPo+WFrOS6pOWcuuermSIsImluZGV4IjoxNCwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzM3Njc2LCJsYXRpdHVkZSI6MzkuOTg4NzU5OTk5OTk5OTk5fX1dLCJ0ZXJtaW5hbFN0YXRpb25OYW1lIjoi5LqU6YGT5Y+j5YWs5Lqk5Zy656uZIiwiSUQiOiIxMzQ3IiwiZGVwYXJ0dXJlU3RhdGlvbk5hbWUiOiLogrLmlrDlsI/ljLoifSwibmV4dFN0YXRpb24iOnsibmFtZSI6IuS6lOmBk+WPo+WFrOS6pOWcuuermSIsImluZGV4IjoxNCwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzM3Njc2LCJsYXRpdHVkZSI6MzkuOTg4NzU5OTk5OTk5OTk5fX0sImFwaU9iamVjdCI6eyJuYW1lIjoi5Zyw6ZOB5LqU6YGT5Y+j56uZIiwiaW5kZXgiOjEzLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zMzg4NCwibGF0aXR1ZGUiOjM5Ljk5MzAwMDAwMDAwMDAwMn19fQ=="
        let s = getStationFrom(base64Data: data)
        return s
    }
    
    
    func getAStation_wudaokou_126() -> Station {
        let data = "eyJiZWxvbmdlZFRvTGluZSI6eyJidXNOdW1iZXIiOiLov5DpgJoxMjYiLCJvcGVyYXRpb25UaW1lIjoiNTozMC0yMjozMCIsImNvb3JkcyI6IjExNi4zMTA1LDQwLjA0MzIzLDExNi4zMDg0OCw0MC4wNDY0MiwxMTYuMzA4NDIsNDAuMDQ2NTEsMTE2LjMwODM3LDQwLjA0NjUsMTE2LjMwNjA0LDQwLjA0NTg2LDExNi4zMDU5NSw0MC4wNDU4NSwxMTYuMzA1NDUsNDAuMDQ1OTMsMTE2LjMwNTM4LDQwLjA0NTk2LDExNi4zMDUyMyw0MC4wNDYsMTE2LjMwNTA4LDQwLjA0NTk5LDExNi4zMDUwMiw0MC4wNDU5OCwxMTYuMzA0OTUsNDAuMDQ1OTUsMTE2LjMwNDksNDAuMDQ1OTIsMTE2LjMwNDg1LDQwLjA0NTg3LDExNi4zMDQ4Miw0MC4wNDU4NSwxMTYuMzA0NzcsNDAuMDQ1NzQsMTE2LjMwNDc2LDQwLjA0NTY3LDExNi4zMDQ3Niw0MC4wNDU1LDExNi4zMDQ4Miw0MC4wNDUzOCwxMTYuMzA0OSw0MC4wNDUzMSwxMTYuMzA0OTMsNDAuMDQ1MjksMTE2LjMwNTA1LDQwLjA0NTI0LDExNi4zMDUyNCw0MC4wNDUyMSwxMTYuMzA1MzksNDAuMDQ1MTYsMTE2LjMwNTUyLDQwLjA0NTAyLDExNi4zMTAxNCw0MC4wMzcwOCwxMTYuMzEwNTgsNDAuMDM2MTgsMTE2LjMxMjksNDAuMDM2ODEsMTE2LjMxMjkzLDQwLjAzNjczLDExNi4zMTQ4Myw0MC4wMzcyMSwxMTYuMzE0OSw0MC4wMzczMiwxMTYuMzE1MjksNDAuMDM3NDEsMTE2LjMxNTYzLDQwLjAzNzQxLDExNi4zMTYxOSw0MC4wMzc1LDExNi4zMTY0Myw0MC4wMzc1MiwxMTYuMzE2NDgsNDAuMDM3NTMsMTE2LjMxNjg1LDQwLjAzNzUzLDExNi4zMTk0Nyw0MC4wMzcyMSwxMTYuMzE5Niw0MC4wMzcxOCwxMTYuMzIwNDksNDAuMDM2ODQsMTE2LjMyMDcxLDQwLjAzNjc4LDExNi4zMjA4Myw0MC4wMzY3NiwxMTYuMzIwOTUsNDAuMDM2NzUsMTE2LjMyMzQsNDAuMDM1ODksMTE2LjMyMzc0LDQwLjAzNDExLDExNi4zMjQ1Miw0MC4wMzEwOCwxMTYuMzI0NjksNDAuMDMxMDIsMTE2LjMyNTI4LDQwLjAzMTA3LDExNi4zMzY5NSw0MC4wMzA4OCwxMTYuMzM2ODgsNDAuMDI1NTYsMTE2LjMzNzMsNDAuMDE0OSwxMTYuMzM5NDMsNDAuMDE0OTQsMTE2LjMzOTYsNDAuMDE0OTEsMTE2LjM0NDE4LDQwLjAxNTA0LDExNi4zNDQzLDQwLjAxNTA5LDExNi4zNDU0MSw0MC4wMTUxLDExNi4zNDU1NSw0MC4wMTUwNiwxMTYuMzUyMDUsNDAuMDE1MjIsMTE2LjM1MjQxLDQwLjAwODY2LDExNi4zNTIzNiw0MC4wMDc5OCwxMTYuMzUyMzEsNDAuMDA3NjQsMTE2LjM1MzAyLDM5Ljk5MzQsMTE2LjM0ODI5LDM5Ljk5MzI2LDExNi4zNDgxOSwzOS45OTMyNSwxMTYuMzM4NzksMzkuOTkzLDExNi4zMzg0NCwzOS45OTI5OCwxMTYuMzM4MDksMzkuOTkyOTgsMTE2LjMzODAzLDM5Ljk5Mjk3LDExNi4zMTU4OSwzOS45OTIxOCwxMTYuMzE1ODIsMzkuOTkyNjQsMTE2LjMxNTIxLDM5Ljk5ODQ4LDExNi4zMTUyNCw0MC4wMDQ0LDExNi4zMTUyOSw0MC4wMDQ3MSwxMTYuMzE1NDQsNDAuMDA1LDExNi4zMTU3NCw0MC4wMDUzOSwxMTYuMzE1OTEsNDAuMDA1NTQsMTE2LjMxNjE5LDQwLjAwNTcxLDExNi4zMTY0Niw0MC4wMDU4NCwxMTYuMzE2ODEzLDQwLjAwNTkzNywxMTYuMzE3MDYsNDAuMDA1OTksMTE2LjMxODM2LDQwLjAwNjE2LDExNi4zMTg2NCw0MC4wMDYyNCwxMTYuMzE4ODcsNDAuMDA2MzcsMTE2LjMxOTA4LDQwLjAwNjU1LDExNi4zMTkxOCw0MC4wMDY3MywxMTYuMzE5MjQsNDAuMDA2OTEsMTE2LjMxOTI2LDQwLjAwNzA4LDExNi4zMTgyMSw0MC4wMTQ5MiwxMTYuMzE4MTksNDAuMDE0OTgsMTE2LjMxODEyLDQwLjAxNTM2LDExNi4zMTc4Myw0MC4wMTYxNCwxMTYuMzE3Niw0MC4wMTgxOCIsInN0YXRpb25zIjpbeyJuYW1lIjoi5LiK5Zyw5YWt6KGX5Lic5Y+jIiwiaW5kZXgiOjEsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjMxMDAzNjk5OTk5OTk5LCJsYXRpdHVkZSI6NDAuMDQzOTYxMDAwMDAwMDAzfX0seyJuYW1lIjoi5LiK5Zyw5LiD6KGX546v5bKb5LicIiwiaW5kZXgiOjIsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjMwNjU1LCJsYXRpdHVkZSI6NDAuMDQ1OTg1MDAwMDAwMDAyfX0seyJuYW1lIjoi5LiK5Zyw5LiD6KGXIiwiaW5kZXgiOjMsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjMwNTU4MDAwMDAwMDAxLCJsYXRpdHVkZSI6NDAuMDQ0OTE5fX0seyJuYW1lIjoi5LiK5Zyw5LqU6KGXIiwiaW5kZXgiOjQsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjMwODM3Njk5OTk5OTk5LCJsYXRpdHVkZSI6NDAuMDQwMDk4fX0seyJuYW1lIjoi5LiK5Zyw5LiJ6KGX5Lic5Y+jIiwiaW5kZXgiOjUsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjMxMzQ1Mzk5OTk5OTk5LCJsYXRpdHVkZSI6NDAuMDM2ODYxOTk5OTk5OTk5fX0seyJuYW1lIjoi5LiK5Zyw5qGl5LicIiwiaW5kZXgiOjYsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjMyMTU2MiwibGF0aXR1ZGUiOjQwLjAzNjUzNTAwMDAwMDAwMX19LHsibmFtZSI6IuacseaIv+i3r+ilv+WPoyIsImluZGV4Ijo3LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zMjYwODUwMDAwMDAwMSwibGF0aXR1ZGUiOjQwLjAzMTA3NzAwMDAwMDAwM319LHsibmFtZSI6Iua4heays+S4reihl+ilv+WPoyIsImluZGV4Ijo4LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zMzI1MSwibGF0aXR1ZGUiOjQwLjAzMDkzNTk5OTk5OTk5N319LHsibmFtZSI6Iua4heays+S4reihlyIsImluZGV4Ijo5LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zMzQ5MzcsImxhdGl0dWRlIjo0MC4wMzA5MDR9fSx7Im5hbWUiOiLmr5vnurrot6/ljZflj6MiLCJpbmRleCI6MTAsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjMzNjg5NSwibGF0aXR1ZGUiOjQwLjAyODc5ODk5OTk5OTk5OX19LHsibmFtZSI6IuWQjuWFq+Wutui3r+WMl+WPoyIsImluZGV4IjoxMSwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzM3MTgzOTk5OTk5OTksImxhdGl0dWRlIjo0MC4wMTgzNjA5OTk5OTk5OTl9fSx7Im5hbWUiOiLlhavlrrblmInlm60iLCJpbmRleCI6MTIsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjM0MjYxMTAwMDAwMDAxLCJsYXRpdHVkZSI6NDAuMDE1MDAzfX0seyJuYW1lIjoi5pyI5rOJ6Lev5Lic5Y+jIiwiaW5kZXgiOjEzLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zNDk1NzcsImxhdGl0dWRlIjo0MC4wMTUxMzU5OTk5OTk5OTh9fSx7Im5hbWUiOiLlrabnn6Xlm60iLCJpbmRleCI6MTQsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjM1MjA3MjAwMDAwMDAxLCJsYXRpdHVkZSI6NDAuMDE0ODYxMDAwMDAwMDAzfX0seyJuYW1lIjoi6Z2Z5reR6IuRIiwiaW5kZXgiOjE1LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zNTI0NTM5OTk5OTk5OSwibGF0aXR1ZGUiOjQwLjAwNDA4ODAwMDAwMDAwM319LHsibmFtZSI6IuWtpumZoui3r+WMl+WPoyIsImluZGV4IjoxNiwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzUyODI0LCJsYXRpdHVkZSI6MzkuOTk2OTg5OTk5OTk5OTk3fX0seyJuYW1lIjoi5oiQ5bqc6Lev5Y+j6KW/IiwiaW5kZXgiOjE3LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zNTAwNiwibGF0aXR1ZGUiOjM5Ljk5MzMwOTAwMDAwMDAwNH19LHsibmFtZSI6IuWMl+S6rOivreiogOWkp+WtpiIsImluZGV4IjoxOCwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzQ0NTksImxhdGl0dWRlIjozOS45OTMxNDMwMDAwMDAwMDN9fSx7Im5hbWUiOiLlnLDpk4HkupTpgZPlj6Pnq5kiLCJpbmRleCI6MTksImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjMzODcyLCJsYXRpdHVkZSI6MzkuOTkyOTkyMDAwMDAwMDAxfX0seyJuYW1lIjoi5LqU6YGT5Y+jIiwiaW5kZXgiOjIwLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zMzQ4NTcsImxhdGl0dWRlIjozOS45OTI4NzEwMDAwMDAwMDF9fSx7Im5hbWUiOiLmuIXljY7lm60iLCJpbmRleCI6MjEsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjMyNzg4MywibGF0aXR1ZGUiOjM5Ljk5MjYyNDk5OTk5OTk5N319LHsibmFtZSI6IuiTneaXl+iQpSIsImluZGV4IjoyMiwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzIzNDk0LCJsYXRpdHVkZSI6MzkuOTkyNDg1MDAwMDAwMDAyfX0seyJuYW1lIjoi5Lit5YWz5Zut5YyX56uZIiwiaW5kZXgiOjIzLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zMTU1MDYsImxhdGl0dWRlIjozOS45OTU3MTAwMDAwMDAwMDN9fSx7Im5hbWUiOiLmuIXljY7lpKflrabopb/pl6giLCJpbmRleCI6MjQsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjMxNTM0MywibGF0aXR1ZGUiOjM5Ljk5NzMwOTAwMDAwMDAwMX19LHsibmFtZSI6IuWchuaYjuWbreS4nOi3ryIsImluZGV4IjoyNSwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzE1MjMxOTk5OTk5OTksImxhdGl0dWRlIjo0MC4wMDQyNjAwMDAwMDAwMDJ9fSx7Im5hbWUiOiLmuIXljY7pmYTkuK0iLCJpbmRleCI6MjYsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjMxODgxNCwibGF0aXR1ZGUiOjQwLjAxMDE1OTk5OTk5OTk5OX19LHsibmFtZSI6IuWOoueZveaXl+ahpSIsImluZGV4IjoyNywibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzE3NzEyLCJsYXRpdHVkZSI6NDAuMDE4MTg2fX1dLCJ0ZXJtaW5hbFN0YXRpb25OYW1lIjoi5Y6i55m95peX5qGlIiwiSUQiOiIxMTg1IiwiZGVwYXJ0dXJlU3RhdGlvbk5hbWUiOiLkuIrlnLDlha3ooZfkuJzlj6MifSwibmV4dFN0YXRpb24iOnsibmFtZSI6IuS6lOmBk+WPoyIsImluZGV4IjoyMCwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzM0ODU3LCJsYXRpdHVkZSI6MzkuOTkyODcxMDAwMDAwMDAxfX0sImFwaU9iamVjdCI6eyJuYW1lIjoi5Zyw6ZOB5LqU6YGT5Y+j56uZIiwiaW5kZXgiOjE5LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zMzg3MiwibGF0aXR1ZGUiOjM5Ljk5Mjk5MjAwMDAwMDAwMX19fQ=="
        let s = getStationFrom(base64Data: data)
        return s
    }
    
    
    func getAStation_东内小街_106() -> Station {
        let data = "eyJiZWxvbmdlZFRvTGluZSI6eyJidXNOdW1iZXIiOiIxMDYiLCJvcGVyYXRpb25UaW1lIjoiNDo1MC0yMzowMCIsImNvb3JkcyI6IjExNi4zNzY3MywzOS44NjY3LDExNi4zNzY1NiwzOS44NjY2MSwxMTYuMzc2MzcsMzkuODY2NDUsMTE2LjM3NjMsMzkuODY2MzcsMTE2LjM3NjI0LDM5Ljg2NjI4LDExNi4zNzYyMSwzOS44NjYxOSwxMTYuMzc2MiwzOS44NjYxLDExNi4zNzYyMSwzOS44NjYwMiwxMTYuMzc2MjUsMzkuODY1ODksMTE2LjM3NjI4LDM5Ljg2NTg1LDExNi4zNzYzLDM5Ljg2NTgzLDExNi4zNzYzMywzOS44NjU4MSwxMTYuMzc2NCwzOS44NjU4LDExNi4zNzY0OCwzOS44NjU4LDExNi4zNzY1NSwzOS44NjU4MiwxMTYuMzc2NjEsMzkuODY1ODcsMTE2LjM3Njk5LDM5Ljg2NjEzLDExNi4zNzcwNCwzOS44NjYxNCwxMTYuMzc3MDcsMzkuODY2MTIsMTE2LjM3NzA5LDM5Ljg2NjA5LDExNi4zNzcwNywzOS44NjYwMSwxMTYuMzc2NzgsMzkuODY1NTgsMTE2LjM3NjcxLDM5Ljg2NTUsMTE2LjM3NjU5LDM5Ljg2NTQxLDExNi4zNzY1MSwzOS44NjUzNywxMTYuMzc2NDEsMzkuODY1MzQsMTE2LjM3NjI4LDM5Ljg2NTM2LDExNi4zNzU4MywzOS44NjU1NSwxMTYuMzc1NjksMzkuODY1NjYsMTE2LjM3NTYyLDM5Ljg2NTczLDExNi4zNzU1NiwzOS44NjU4MiwxMTYuMzc1NTUsMzkuODY1ODgsMTE2LjM3NTU1LDM5Ljg2NTkyLDExNi4zNzU1OCwzOS44NjYwMiwxMTYuMzc1NjIsMzkuODY2MDgsMTE2LjM3NTY4LDM5Ljg2NjE0LDExNi4zNzY2OCwzOS44NjY4NSwxMTYuMzc2NzMsMzkuODY2OSwxMTYuMzc2NzcsMzkuODY2OTMsMTE2LjM3NjgxLDM5Ljg2Njk4LDExNi4zNzY5NCwzOS44NjcyNCwxMTYuMzc2OTgsMzkuODY3NjIsMTE2LjM3NzU2LDM5Ljg2NzY5LDExNi4zNzc2LDM5Ljg2NzY5LDExNi4zNzk3NiwzOS44Njc5OCwxMTYuMzc5OCwzOS44Njc5OCwxMTYuMzgzLDM5Ljg2ODI2LDExNi4zODMwMiwzOS44NjgzNSwxMTYuMzgyOTcsMzkuODY4OTksMTE2LjM4MjgyLDM5Ljg3MDU5LDExNi4zODI4NiwzOS44NzA2NSwxMTYuMzg1NTQsMzkuODcwODIsMTE2LjM4NTYyLDM5Ljg3MDg3LDExNi4zODU4NCwzOS44NzA5OCwxMTYuMzg3NywzOS44NzEwOSwxMTYuMzg3NzcsMzkuODcxMSwxMTYuMzg5NTEsMzkuODcxMiwxMTYuMzkwMDgsMzkuODcxMTUsMTE2LjM5MDE1LDM5Ljg3MTA4LDExNi4zOTAxOSwzOS44NzEwMiwxMTYuMzkwMjEsMzkuODcwOTUsMTE2LjM5MDIxLDM5Ljg3MDkzLDExNi4zOTAyLDM5Ljg3MDkxLDExNi4zOTAxOSwzOS44NzA4OCwxMTYuMzkwMTcsMzkuODcwODUsMTE2LjM5MDE2LDM5Ljg3MDgzLDExNi4zOTAxMywzOS44NzA4MSwxMTYuMzkwMTEsMzkuODcwOCwxMTYuMzkwMDgsMzkuODcwNzksMTE2LjM4ODIsMzkuODcwOCwxMTYuMzg4MTYsMzkuODcwODEsMTE2LjM4ODA4LDM5Ljg3MDg0LDExNi4zODgwNCwzOS44NzA4NiwxMTYuMzg3OTUsMzkuODcwOTgsMTE2LjM4Nzk0LDM5Ljg3MTU1LDExNi4zODc5NSwzOS44NzE3MywxMTYuMzg3NTEzLDM5Ljg4MTQwNywxMTYuMzg3NDYsMzkuODgzMTcsMTE2LjM4NzM4LDM5Ljg4MzM3LDExNi4zOTY4MywzOS44ODM2NCwxMTYuMzk4NjgsMzkuODgzNTcsMTE2LjM5OSwzOS44ODM1OSwxMTYuMzk4ODEsMzkuODg2MTUsMTE2LjM5ODU5LDM5Ljg4NjQ3LDExNi4zOTk5NSwzOS44ODY2NiwxMTYuNDAwMSwzOS44ODY2NCwxMTYuNDAzNDMsMzkuODg3NTksMTE2LjQwNDM0LDM5Ljg4NzgsMTE2LjQwNDM3LDM5Ljg4NzgxLDExNi40MDUzOCwzOS44ODc5NiwxMTYuNDA3NzUsMzkuODg4MSwxMTYuNDExNjcsMzkuODg4MjEsMTE2LjQxMTc5LDM5Ljg4ODI3LDExNi40MTU0MSwzOS44ODgzNSwxMTYuNDE1NTQsMzkuODg4MjksMTE2LjQxNjU4LDM5Ljg4ODE1LDExNi40MTY4OCwzOS44ODgwOSwxMTYuNDE3LDM5Ljg4ODA1LDExNi40MTcxOCwzOS44ODgwMSwxMTYuNDE3NTcsMzkuODg3ODgsMTE2LjQxOTQ2LDM5Ljg4NzAzLDExNi40MTk1NywzOS44ODcwMSwxMTYuNDE5NjQsMzkuODg3MDEsMTE2LjQxOTE4LDM5Ljg4ODA3LDExNi40MTkwOCwzOS44ODkwNywxMTYuNDE5LDM5Ljg5MjEzLDExNi40MTkwMywzOS44OTI1NCwxMTYuNDE5MDIsMzkuODkyNjEsMTE2LjQxODk4LDM5Ljg5MzYyLDExNi40MTg1NiwzOS45MDA5NSwxMTYuNDE4NTMsMzkuOTAxMDQsMTE2LjQxODUzLDM5LjkwMTExLDExNi40MTgzOCwzOS45MDQxNywxMTYuNDE4LDM5LjkxMDU1LDExNi40MTc5MiwzOS45MTA2NiwxMTYuNDE3NjQsMzkuOTIxOSwxMTYuNDE3NjIsMzkuOTIxOTgsMTE2LjQxNzIzLDM5LjkzMjI0LDExNi40MTcyMiwzOS45MzIzLDExNi40MTcyNiwzOS45MzI0NywxMTYuNDE3MTgsMzkuOTM0ODcsMTE2LjQxNzE0LDM5LjkzNTAyLDExNi40MTY4NiwzOS45NDA4NCwxMTYuNDE2OTcsMzkuOTQwODUsMTE2LjQyNTYxLDM5Ljk0MDk2LDExNi40MzI5OCwzOS45NDEwMiwxMTYuNDMzMDYsMzkuOTQwOTksMTE2LjQzMzE3LDM5Ljk0MDkzLDExNi40MzMyLDM5Ljk0MDg3LDExNi40MzMyNSwzOS45NDA4MywxMTYuNDMzMzEsMzkuOTQwOCwxMTYuNDMzMzcsMzkuOTQwNzgsMTE2LjQzMzU1LDM5Ljk0MDc2LDExNi40MzM1OSwzOS45NDA3NywxMTYuNDMzNzEsMzkuOTQwNzcsMTE2LjQzMzgxLDM5Ljk0MDc4LDExNi40MzQyMiwzOS45NDA4LDExNi40MzQzNywzOS45NDA4MywxMTYuNDM0NTQsMzkuOTQwOTIsMTE2LjQzNDU4LDM5Ljk0MDk2LDExNi40MzQ2NiwzOS45NDEwMiwxMTYuNDM0NzEsMzkuOTQxMDQsMTE2LjQzNDgsMzkuOTQxMDYsMTE2LjQzODgxLDM5Ljk0MTA5LDExNi40MzkwNSwzOS45NDEyMiwxMTYuNDM5MDMsMzkuOTQxNTgiLCJzdGF0aW9ucyI6W3sibmFtZSI6IuWMl+S6rOWNl+ermSIsImluZGV4IjoxLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zNzYyMjEsImxhdGl0dWRlIjozOS44NjY1MTg5OTk5OTk5OTd9fSx7Im5hbWUiOiLmsLjlrprpl6jplb/pgJTmsb3ovabnq5kiLCJpbmRleCI6MiwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuMzgyOTM2LCJsYXRpdHVkZSI6MzkuODY5MzI5OTk5OTk5OTk4fX0seyJuYW1lIjoi6Zm254S25qGl5YyXIiwiaW5kZXgiOjMsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjM4Nzg2MywibGF0aXR1ZGUiOjM5Ljg3MzYwMDAwMDAwMDAwM319LHsibmFtZSI6IuWkquW5s+ihlyIsImluZGV4Ijo0LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi4zODc1NDI5OTk5OTk5OSwibGF0aXR1ZGUiOjM5Ljg4MDI2fX0seyJuYW1lIjoi5YyX57qs6LevIiwiaW5kZXgiOjUsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjM4ODc0LCJsYXRpdHVkZSI6MzkuODgzMzg5OTk5OTk5OTk5fX0seyJuYW1lIjoi5YyX57qs6Lev5Lic5Y+jIiwiaW5kZXgiOjYsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjM5NTkzMDAwMDAwMDAxLCJsYXRpdHVkZSI6MzkuODgzNjA5OTk5OTk5OTk3fX0seyJuYW1lIjoi5aSp5qGlIiwiaW5kZXgiOjcsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjM5ODg5MiwibGF0aXR1ZGUiOjM5Ljg4NTI2OTAwMDAwMDAwMX19LHsibmFtZSI6IumHkemxvOaxoCIsImluZGV4Ijo4LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi40MDYzLCJsYXRpdHVkZSI6MzkuODg4MDM1MDAwMDAwMDAyfX0seyJuYW1lIjoi5aSp5Z2b5YyX6ZeoIiwiaW5kZXgiOjksImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjQxMTU0LCJsYXRpdHVkZSI6MzkuODg4MjEwMDAwMDAwMDAxfX0seyJuYW1lIjoi57qi5qGl6Lev5Y+j5YyXIiwiaW5kZXgiOjEwLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi40MTkwNTcsImxhdGl0dWRlIjozOS44ODk4MDk5OTk5OTk5OTd9fSx7Im5hbWUiOiLno4Hlmajlj6PljJciLCJpbmRleCI6MTEsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjQxODkxMywibGF0aXR1ZGUiOjM5Ljg5NDM2ODk5OTk5OTk5OH19LHsibmFtZSI6IuW0h+aWh+mXqOWGhSIsImluZGV4IjoxMiwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuNDE4MzgsImxhdGl0dWRlIjozOS45MDQ0NzAwMDAwMDAwMDN9fSx7Im5hbWUiOiLkuJzljZXot6/lj6PljJciLCJpbmRleCI6MTMsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjQxNzkyLCJsYXRpdHVkZSI6MzkuOTEwOTEwMDAwMDAwMDAxfX0seyJuYW1lIjoi57Gz5biC5aSn6KGXIiwiaW5kZXgiOjE0LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi40MTc4ODMsImxhdGl0dWRlIjozOS45MTQwMDAwMDAwMDAwMDF9fSx7Im5hbWUiOiLnga/luILkuJzlj6MiLCJpbmRleCI6MTUsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjQxNzY2NiwibGF0aXR1ZGUiOjM5LjkyMDI3OTk5OTk5OTk5OH19LHsibmFtZSI6IuS4nOWbm+i3r+WPo+WNlyIsImluZGV4IjoxNiwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuNDE3NTcsImxhdGl0dWRlIjozOS45MjMwNn19LHsibmFtZSI6IumSseeyruiDoeWQjCIsImluZGV4IjoxNywibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuNDE3Mzk0LCJsYXRpdHVkZSI6MzkuOTI3NzA5OTk5OTk5OTk4fX0seyJuYW1lIjoi6a2P5a626IOh5ZCMIiwiaW5kZXgiOjE4LCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi40MTcyNDIsImxhdGl0dWRlIjozOS45MzE5NTk5OTk5OTk5OTd9fSx7Im5hbWUiOiLkuJzlm5vljYHkuozmnaEiLCJpbmRleCI6MTksImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjQxNzExMiwibGF0aXR1ZGUiOjM5LjkzNjAzOTk5OTk5OTk5OH19LHsibmFtZSI6IuWMl+aWsOahpei3r+WPo+WNlyIsImluZGV4IjoyMCwibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuNDE2OTYsImxhdGl0dWRlIjozOS45MzkyMzAwMDAwMDAwMDJ9fSx7Im5hbWUiOiLkuJzlhoXlsI/ooZciLCJpbmRleCI6MjEsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjQyNDc1LCJsYXRpdHVkZSI6MzkuOTQwOTUwMDAwMDAwMDAxfX0seyJuYW1lIjoi5Lic55u06Zeo5YaFIiwiaW5kZXgiOjIyLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi40MzEyOCwibGF0aXR1ZGUiOjM5Ljk0MTAwNzk5OTk5OTk5N319LHsibmFtZSI6IuS4nOebtOmXqOaeoue6veermSIsImluZGV4IjoyMywibG9jYXRpb24iOnsibG9uZ2l0dWRlIjoxMTYuNDM5MDI2LCJsYXRpdHVkZSI6MzkuOTQxNjR9fV0sInRlcm1pbmFsU3RhdGlvbk5hbWUiOiLkuJznm7Tpl6jmnqLnur3nq5kiLCJJRCI6IjE2MCIsImRlcGFydHVyZVN0YXRpb25OYW1lIjoi5YyX5Lqs5Y2X56uZIn0sIm5leHRTdGF0aW9uIjp7Im5hbWUiOiLkuJznm7Tpl6jlhoUiLCJpbmRleCI6MjIsImxvY2F0aW9uIjp7ImxvbmdpdHVkZSI6MTE2LjQzMTI4LCJsYXRpdHVkZSI6MzkuOTQxMDA3OTk5OTk5OTk3fX0sImFwaU9iamVjdCI6eyJuYW1lIjoi5Lic5YaF5bCP6KGXIiwiaW5kZXgiOjIxLCJsb2NhdGlvbiI6eyJsb25naXR1ZGUiOjExNi40MjQ3NSwibGF0aXR1ZGUiOjM5Ljk0MDk1MDAwMDAwMDAwMX19fQ=="
        let s = getStationFrom(base64Data: data)
        return s
    }
    
    private func getStationFrom(base64Data: String) -> Station {
        let jsonData = Data(base64Encoded: base64Data, options: [])!
        let s = try! JSONDecoder().decode(Station.self, from: jsonData)
        return s
    }
}
