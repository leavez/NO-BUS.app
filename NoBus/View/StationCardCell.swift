//
//  StationCardCell.swift
//  NoBus
//
//  Created by Gao on 2018/10/28.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit
import Stevia

class StationCardCell: UICollectionViewCell {
    
    let stataionNameLabel = UILabel()
    let contentLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentLabel.numberOfLines = 0
        contentView.sv(
            stataionNameLabel,
            contentLabel
        )
        contentView.layout(
            30,
            |-40-stataionNameLabel-100-|,
            30,
            contentLabel,
            0
        )
//        contentView.Width >= 300
        
        stataionNameLabel.style {
            $0.font = UIFont.boldSystemFont(ofSize: 30)
        }
        
        self.layer.cornerRadius = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
