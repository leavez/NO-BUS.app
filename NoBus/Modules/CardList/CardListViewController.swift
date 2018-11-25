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



class CardListViewController: UIViewController {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let viewModel = MainListViewModel()
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
//            self.present(ManageViewController(), animated: true, completion: nil)
        }
        view.sv(collectionView)
        view.layout(
            0,
            |collectionView|,
            0
        )
        collectionView.style { (collectionView) in
            collectionView.register(StationCardCell.self, forCellWithReuseIdentifier: "cell")
            collectionView.register(SettingCell.self, forCellWithReuseIdentifier: SettingCell.settingIdentifier)
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
            layout.estimatedItemSize = CGSize(width: 100, height: 100)
            layout.minimumInteritemSpacing = 30
            layout.minimumLineSpacing = 30
            collectionView.backgroundColor = .white // UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1)
            collectionView.alwaysBounceVertical = true
        }
        

        
        let dataSource = RxCollectionViewSectionedReloadDataSource<ItemViewModel.Section> (configureCell: {
                (datasource, collectionView, index, i) -> UICollectionViewCell in
            if i.name == SettingCell.settingIdentifier {
                return collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.settingIdentifier, for: index)
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: index) as? StationCardCell
                cell?.bind(viewModel: i)
                return cell ?? UICollectionViewCell()
            }
        })
        
        viewModel.items.asObservable()
            .map({
                let fakeSettingSection: ItemViewModel.Section = {
                    let setting = ItemViewModel.StationCell(stationName: SettingCell.settingIdentifier, lines: [])
                    var section = ItemViewModel.Section()
                    section.stations = [setting]
                    return section
                }()
                return $0 + [fakeSettingSection]
            })
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
    
  
//    func settingEntrance() -> UIView {
//        
//    }

}

class SettingCell: StationCardCell {
    static let settingIdentifier = "setting"
    
    let title = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        contentView.sv(title)
        title.fillContainer(20)
        title.setTitle("SETTING", for: .normal)
        title.titleLabel?.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        title.setTitleColor(UIColor.table.subDescription.light, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

