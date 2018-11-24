//
//  InputViewController.swift
//  NoBus
//
//  Created by Gao on 2018/11/14.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit
import Stevia
import RxSwift

class ManageViewController: UIViewController {
    
    let closeButton = BigCloseButton()
    let addButton = BigCloseButton()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    let viewModel = ManageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sv(tableView, closeButton, addButton)
        tableView.fillContainer()
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 80
        closeButton.top(20).left(20)
        addButton.top(20).right(20)

        viewModel.output.items.bind(to: tableView.rx.items(cellIdentifier: "cell")) {
            (index, data, cell) in
            guard let searchCell = cell as? SearchResultCell else { return }
            searchCell.bind(data: data)
            }.disposed(by: bag)
        
        // others
        closeButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            self?.view.endEditing(true)
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
        
        addButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            self?.present(SearchViewController(), animated: true, completion: nil)
        }).disposed(by: bag)
    }
    
    private let bag = DisposeBag()
}
