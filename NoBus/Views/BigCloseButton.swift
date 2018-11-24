//
//  BigCloseButton.swift
//  NoBus
//
//  Created by leave on 2018/11/15.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit

class BigCloseButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTitle("X", for: .normal)
        self.setTitleColor(UIColor(white: 0.5, alpha: 1), for: .normal)
        titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
