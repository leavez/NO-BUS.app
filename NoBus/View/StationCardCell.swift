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
    let itemsView = UIStackView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.sv(
            stataionNameLabel,
            itemsView
        )
        contentView.layout(
            30,
            |-(15)-stataionNameLabel-100-|,
            20,
            |-10-itemsView-10-|,
            30
        )
        
        self.style {
//            $0.layer.borderWidth = 0.5
//            $0.layer.borderColor = UIColor.darkGray.cgColor
            $0.backgroundColor = .white
            $0.layer.shadowRadius = 20
            $0.layer.shadowColor = UIColor.darkGray.cgColor
            $0.layer.shadowOpacity = 0.2
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        }
        
        stataionNameLabel.style {
            $0.font = UIFont.boldSystemFont(ofSize: 25)
            $0.textColor = UIColor(white: 0.2, alpha: 1)
        }
        itemsView.style {
            $0.spacing = 10
            $0.axis = .vertical
        }
        
        self.layer.cornerRadius = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViewModelData(_ data:DisplayModel.Station) {
        let lineViews = data.lines.map { (line) -> UIView in
            let v = LineItemView()
            v.setUp(data: line)
            return v
        }
        lineViews.forEach { (v) in
            self.itemsView.addArrangedSubview(v)
        }
    }
}


class LineItemView: UIView {
    
    static fileprivate let cornerRaius: CGFloat = 12
    
    let lineNumberLabel = UILabel()
    let remainDistanceLabel = UILabel()
    let remainTimeLabel = UILabel()
    let updatedTimeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.sv(
            lineNumberLabel,
            remainDistanceLabel,
            remainTimeLabel
        )
        
        self.layout(
            |-10-lineNumberLabel-10-remainDistanceLabel-|
        )
        
        self.style {
            $0.layer.shadowRadius = 5
            $0.layer.shadowColor = UIColor.darkGray.cgColor
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.cornerRadius = LineItemView.cornerRaius
//            $0.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
//            $0.layer.borderWidth = 0.5
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 60)
    }
    
    func setUp(data: DisplayModel.Line) {
        lineNumberLabel.text = data.name
        remainTimeLabel.text = "\(Double(data.distanceRemain) / 60.0) mins"
    }
}
