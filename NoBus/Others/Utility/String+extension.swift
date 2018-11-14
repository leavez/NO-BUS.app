//
//  String+extension.swift
//  NoBus
//
//  Created by leave on 2018/11/14.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation

extension String {
    
    func transformToPinYin() -> String {
        
        let mutableString = NSMutableString(string: self)
        //把汉字转为拼音
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        //去掉拼音的音标
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        //去掉空格
        return string.replacingOccurrences(of: " ", with: "")
    }
}

