//
//  ViewController.swift
//  NoBus
//
//  Created by Gao on 2018/10/24.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit
import fucking_beijing_bus_api
import Alamofire
import Stevia
import RxSwift
import RxCocoa
import RxDataSources



class ViewController: UIViewController {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let viewModel = MainListViewModel()
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        layout.estimatedItemSize = CGSize(width: 100, height: 100)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(StationCardCell.self, forCellWithReuseIdentifier: "cell")
        view.sv(collectionView)
        view.layout(
            0,
            |collectionView|,
            0
        )
        

        
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<DisplayModel.Group> (configureCell: {
                (datasource, collectionView, index, i) -> UICollectionViewCell in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: index) as? StationCardCell
                cell?.backgroundColor = .orange
                cell?.stataionNameLabel.text = i.name
                cell?.contentLabel.text = i.lines.map { $0.name }.joined(separator: "\n")
                return cell ?? UICollectionViewCell()
            })
        
        viewModel.items.asObservable()
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        

        
//        viewModel.items.asObservable()
//            .bind(to: collectionView.rx.items(cellIdentifier: "cell")) {
//                (index, item: [String], cell) in
//                cell.backgroundColor = .white
//            }

        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(load))
//        textView.addGestureRecognizer(tap)
    }
    
  

}

