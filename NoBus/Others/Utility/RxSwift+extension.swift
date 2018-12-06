//
//  RxSwift+extension.swift
//  NoBus
//
//  Created by Gao on 2018/12/7.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import RxSwift

extension Observable {
    
    func anyObservable() -> Observable<AnyObject> {
        return self.map{ $0 as AnyObject }
    }
}
