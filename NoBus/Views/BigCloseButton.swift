//
//  BigCloseButton.swift
//  NoBus
//
//  Created by leave on 2018/11/15.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit

class AlphaButton: UIButton {
    convenience init() {
        self.init(type: .system)
    }
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        let newImage = image?.withRenderingMode(.alwaysOriginal)
        super.setImage(newImage, for: state)
    }
}

class BigCloseButton: AlphaButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(UIImage(named: "close"), for: .normal)
        titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title2)
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
