//
//  StationCardCell.swift
//  NoBus
//
//  Created by Gao on 2018/10/28.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit
import Stevia
import RxSwift
import RxCocoa

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
            |-(15)-stataionNameLabel-15-|,
            20,
            |-10-itemsView-10-|,
            30
        )
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: 310)
            ])
        
        
        self.style {
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor(white: 0.9, alpha: 0.7).cgColor
            $0.backgroundColor = .white
            $0.layer.shadowRadius = 15
            $0.layer.shadowColor = UIColor.darkGray.cgColor
            $0.layer.shadowOpacity = 0.2
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
        
        stataionNameLabel.style {
            $0.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            $0.textColor = UIColor.table.subDescription
            $0.textColor = UIColor.table.largeTitle
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.8
        }
        itemsView.style {
            $0.spacing = 12
            $0.axis = .vertical
        }
        
        self.layer.cornerRadius = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
    
    func bind(viewModel: ItemViewModel.StationCell) {
        
        stataionNameLabel.text = viewModel.name
        viewModel.lines.bind { (data) in
            // remove old
            self.itemsView.arrangedSubviews.forEach {
                self.itemsView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            
            // add new
            let lineViews = data.map { (line) -> UIView in
                let v = LineItemView()
                v.bind(viewModel: line)
                return v
            }
            lineViews.forEach { (v) in
                self.itemsView.addArrangedSubview(v)
            }
        }.disposed(by: reuseDisposeBag)
        
    }
    
    private(set) var reuseDisposeBag = DisposeBag()
}


class LineItemView: UIView {
    
    static fileprivate let cornerRaius: CGFloat = 12
    
    let lineNumberLabel = UILabel()
    let remainDistanceLabel = UILabel()
    let remainTimeLabel = UILabel()
    let updatedTimeLabel = UILabel()
    
    let highlightedView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.sv(
            highlightedView,
            lineNumberLabel,
            remainDistanceLabel,
            remainTimeLabel,
            updatedTimeLabel
        )
        
        lineNumberLabel.Top == self.Top
        lineNumberLabel.Bottom == self.Bottom
        lineNumberLabel.Left == self.Left + 10
        
        remainDistanceLabel.Right == self.Right - 10
        remainDistanceLabel.Top == self.Top + 10
        
        remainTimeLabel.Right == remainDistanceLabel.Left - 10
        remainTimeLabel.CenterY == remainDistanceLabel.CenterY
        remainTimeLabel.Left >= lineNumberLabel.Right + 20
        
        updatedTimeLabel.Top >= remainDistanceLabel.Bottom + 6
        updatedTimeLabel.Right == remainDistanceLabel.Right
        updatedTimeLabel.Bottom == self.Bottom - 10
        
        highlightedView.followEdges(self)
        highlightedView.backgroundColor = UIColor(red: 0.1, green: 1, blue: 0.1, alpha: 0.1)
        highlightedView.isHidden = true
        

        
        
        self.style {
            $0.layer.shadowRadius = 2
            $0.layer.shadowColor = UIColor.darkGray.cgColor
            $0.layer.shadowOpacity = 0.2
            $0.layer.shadowOffset = CGSize(width: 0.3, height: 1)
            $0.layer.cornerRadius = LineItemView.cornerRaius
            
            $0.highlightedView.layer.cornerRadius = $0.layer.cornerRadius
            
            $0.lineNumberLabel.style({
                $0.font = UIFont.preferredFont(forTextStyle: .title2)
                $0.textColor = UIColor.table.title
            })
            for label in [$0.remainDistanceLabel, $0.remainTimeLabel] {
                label.font = .preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
                label.textColor = UIColor.table.subDescription
            }
            $0.updatedTimeLabel.style({ (l) in
                l.font = .preferredFont(forTextStyle: UIFont.TextStyle.footnote)
                l.textColor = UIColor.table.subDescription
            })
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(viewModel: ItemViewModel.StationCell.Line) {
        for t in [
            (\ItemViewModel.StationCell.Line.title, lineNumberLabel),
            (\.distanceRemain, remainDistanceLabel),
            (\.timeRemain, remainTimeLabel),
            (\.updatedTime, updatedTimeLabel)
            ]
        {
            viewModel[keyPath:t.0].bind(to: t.1.rx.text)
                .disposed(by: bag)
        }
    }
    
    private let bag = DisposeBag()
}
