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
    
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    let viewModel = ManageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // style
        self.title = "Settings"
        
        // table view
        view.sv(tableView)
        tableView.fillContainer()
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 80

        viewModel.output.items.bind(to: tableView.rx.items(cellIdentifier: "cell")) {
            (index, data, cell) in
            guard let searchCell = cell as? SearchResultCell else { return }
            searchCell.bind(data: data)
            }.disposed(by: bag)
        
        // others
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))

    }
    
    
    static func embededInNavigationController() -> UIViewController {
        let navi = UINavigationController(rootViewController: self.init())
        navi.modalPresentationStyle = .pageSheet
        navi.navigationBar.prefersLargeTitles = true
        return navi
    }
    
    private let bag = DisposeBag()
    
    @objc private func didTapDone() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func didTapAdd() {
        self.present(SearchViewController(), animated: true, completion: nil)
    }
}

