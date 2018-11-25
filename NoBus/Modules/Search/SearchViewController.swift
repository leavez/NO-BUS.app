//
//  SearchViewController.swift
//  NoBus
//
//  Created by Gao on 2018/11/14.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Stevia
import RxDataSources

class SearchViewController: UIViewController {
    
    let inputField = SearchField()
    let tableView = UITableView()
    let noResultHintView = UILabel()
    let closeButton = BigCloseButton()
    
    let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.binding()
        StationSearchManager.shared.warmUpCache()
        
        view.backgroundColor = UIColor.table.background

        view.sv(
            tableView,
            noResultHintView,
            inputField,
            closeButton
        )
        
        let margin = MarginHelper.margin(for: self) - 12
        
        NSLayoutConstraint.activate([
            inputField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:15),
            inputField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: margin),
            inputField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -margin)
            ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant:0),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        NSLayoutConstraint.activate([
            noResultHintView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultHintView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:-80),
            noResultHintView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8)
            ])
        
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: inputField.centerYAnchor),
            closeButton.rightAnchor.constraint(equalTo: inputField.rightAnchor, constant: -15),
            ])

        tableView.style { v in
            v.register(SearchResultCell.self, forCellReuseIdentifier: "cell")
            v.estimatedRowHeight = 80
            v.tableFooterView = UIView()
            v.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 60, right: 0)
            let margin = MarginHelper.margin(for: self)
            v.separatorInset = UIEdgeInsets(top: 0, left: margin+15, bottom: 0, right: margin)
            v.backgroundColor = UIColor.table.background
        }
        
        noResultHintView.style { (v) in
            v.numberOfLines = 5
            v.textAlignment = .center
            v.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title2)
            v.textColor = UIColor.table.subDescription
        }
        
        // keyboard
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBlank))
        //        tableView.addGestureRecognizer(tap)
        //        view.addGestureRecognizer(tap)
        tableView.keyboardDismissMode = .onDrag
        
        DispatchQueue.main.async {
            self.inputField.realField.becomeFirstResponder()
        }
    }
    
    
    func binding() {
        inputField.realField.rx.text
            .bind(to: viewModel.input.keyword)
            .disposed(by: bag)
        
        
        
        viewModel.output.items.bind(to: tableView.rx.items(cellIdentifier: "cell")) {
            (index, data, cell) in
            guard let searchCell = cell as? SearchResultCell else { return }
            searchCell.bind(data: data)
        }.disposed(by: bag)
        
        let showNoResult = viewModel.output.showHint.share()
        bag.insert(
            showNoResult.map{ !$0 }.bind(to: noResultHintView.rx.isHidden),
            showNoResult.bind(to: tableView.rx.isHidden),
            viewModel.output.hint.bind(to: noResultHintView.rx.text)
        )
        
        // table view action
        
        tableView.rx.modelSelected(Station.self).subscribe(onNext: {[weak self] s in
            // add
            StationsManager.shared.addToSaved(station: s)
            // dismiss
            self?.view.endEditing(true)
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
        
        // others
        closeButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            self?.view.endEditing(true)
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
    }
    
    private let bag = DisposeBag()
    
    @objc private func didTapBlank() {
        self.view.endEditing(true)
    }
    
}


class SearchField: UIView {
    let realField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sv(realField)
        self.layout(
            20,
            |-30-realField-50-|,
            20
        )
        realField.placeholder = "例如：321 学院路 xueyuanlu"
        realField.clearButtonMode = .never
        
        self.style {
            $0.backgroundColor = UIColor.table.cardBackgroud
            
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.table.cardBorder
            
            $0.layer.shadowRadius = 2
            $0.layer.shadowColor = UIColor.table.cardShadowHeavy
            $0.layer.shadowOpacity = 0.2
            $0.layer.shadowOffset = CGSize(width: 0.3, height: 1)
            $0.layer.cornerRadius = 20
        }
        self.realField.style {
            $0.textColor = UIColor.table.plainTitle
        }


        let tap = UITapGestureRecognizer(target: realField, action: #selector(becomeFirstResponder))
        addGestureRecognizer(tap)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SearchResultCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let stationNameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.sv(titleLabel, stationNameLabel)
        let margin = MarginHelper.margin
        contentView.layout(
            15,
            |-(margin+10)-titleLabel-(margin+10)-|,
            3,
            |-(margin+10)-stationNameLabel-(margin+10)-|,
            15
        )
        self.backgroundColor = UIColor.table.background
        titleLabel.style {
            $0.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
            $0.textColor = UIColor.table.plainTitle
        }
        stationNameLabel.style {
            $0.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
            $0.textColor = UIColor.table.subDescription
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(data:Station) {
        titleLabel.text = data.belongedToLine.busNumber
        stationNameLabel.text = data.name + " ( -> " + (data.nextStation?.name ?? "🏁") + " )"
    }
}


