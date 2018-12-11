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
    
    let tableView = UITableView(frame: .zero, style: .plain)
    let viewModel = ManageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sv(tableView, closeButton, addButton)
        let margin = MarginHelper.margin(for: self)
        closeButton.Top == view.safeAreaLayoutGuide.Top + 15
        closeButton.Right == view.safeAreaLayoutGuide.Right - margin
        addButton.Left == view.safeAreaLayoutGuide.Left + margin
        addButton.Top == view.safeAreaLayoutGuide.Top + 15
        tableView.Left == view.Left
        tableView.Right == view.Right
        tableView.Bottom == view.Bottom
        tableView.Top == closeButton.Bottom + 10
        
        // styles
        tableView.style { (v) in
            v.estimatedRowHeight = 80
            v.tableFooterView = UIView()
            v.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 60, right: 0)
            let margin = MarginHelper.margin(for: self)
            v.separatorInset = UIEdgeInsets(top: 0, left: margin+15, bottom: 0, right: margin)
            v.backgroundColor = UIColor.table.background
        }
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 80
        tableView.rx.setDelegate(self).disposed(by: bag)
        self.view.backgroundColor = UIColor.table.background
        
        addButton.style {
            $0.setImage(UIImage(named: "add"), for: .normal)
        }
        

        // VM
        viewModel.output.items.bind(to: tableView.rx.items(cellIdentifier: "cell")) {
            (index, data, cell) in
            guard let searchCell = cell as? SearchResultCell else { return }
            searchCell.bind(data: data)
            }.disposed(by: bag)
        
        // others
        closeButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
        
        addButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            self?.present(SearchViewController(), animated: true, completion: nil)
        }).disposed(by: bag)
        
        tableView.rx.itemSelected.bind {[weak self] (index) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.tableView.deselectRow(at: index, animated: true)
            }
        }.disposed(by: bag)
        
        tableView.rx.modelSelected(Station.self).subscribe(onNext: { model in
            let vc = MapViewController(lines: [model.belongedToLine], referenceStation:model.apiObject)
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: bag)

    }
    
    
    static func embededInNavigationController() -> UIViewController {
        let navi = UINavigationController(rootViewController: self.init())
        navi.navigationBar.tintColor = UIColor.table.largeTitle
        navi.navigationBar.prefersLargeTitles = true
        navi.navigationBar.isHidden = true
        return navi
    }
    
    private let bag = DisposeBag()

}

extension ManageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: "移除", handler: {[unowned self] (action, view, finished) in
                // Wait then animation end, then refresh data.
                // Or the data change may directly trigger table reload, which
                // break the animations.
                let origin = self.view.isUserInteractionEnabled
                self.view.isUserInteractionEnabled = false
                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    if let model: Station = try? self.tableView.rx.model(at: indexPath) {
                        self.viewModel.didTapRemoveStation(station: model)
                    }
                    self.view.isUserInteractionEnabled = origin
                })
                finished(true)
                CATransaction.commit()
            })
        ])
    }

}
