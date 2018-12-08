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
import RxGesture



class CardListViewController: UIViewController {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let refreshButton = RefreshButtonView(type: .system)
    
    let viewModel = MainListViewModel()
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sv(
            collectionView,
            refreshButton
        )
        view.layout(
            0,
            |collectionView|,
            0
        )
        refreshButton
            .size(60)
            .centerHorizontally()
            .bottom(20)
        
        collectionView.style { (collectionView) in
            collectionView.register(StationCardCell.self, forCellWithReuseIdentifier: "cell")
            collectionView.register(SettingCell.self, forCellWithReuseIdentifier: SettingCell.settingIdentifier)
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
            layout.estimatedItemSize = CGSize(width: 300, height: 300)
            layout.minimumInteritemSpacing = 30
            layout.minimumLineSpacing = 30
            collectionView.backgroundColor = UIColor.table.background
            collectionView.alwaysBounceVertical = true
        }
        setupCollectionBehavior()
        


        
        

        
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
        
        refreshButton.bind(vm: viewModel.refreshButtonViewModel)

        
    }
    
  
    func setupCollectionBehavior()  {

        // deselect cell when tap blank area
        collectionView.backgroundView = UIView()
        collectionView.backgroundView?.rx.tapGesture().subscribe(onNext: {
            [unowned self]_ in
            self.collectionView.indexPathsForSelectedItems?.forEach({ index in
                self.collectionView.deselectItem(at: index, animated: true)
            })
        }).disposed(by: bag)
        
        // when seleted setting entrance
        collectionView.rx.modelSelected(ItemViewModel.StationCell.self)
            .filter({ $0.name == SettingCell.settingIdentifier})
            .bind {[unowned self] _ in
                let naviVC = ManageViewController.embededInNavigationController()
                self.present(naviVC, animated: true, completion: nil)
        }.disposed(by: bag)
        
        // temp
        collectionView.rx.modelSelected(ItemViewModel.StationCell.self)
            .filter({ $0.name != SettingCell.settingIdentifier})
            .bind {[unowned self] _ in
            }.disposed(by: bag)

    }

}

class SettingCell: StationCardCell {
    static let settingIdentifier = "identifier.setting"
    
    let title = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        contentView.sv(title)
        title.fillContainer(20)
        title.textAlignment = .center
        title.text = "Settings"
        title.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        title.textColor = UIColor.table.subDescription.light
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var isSelected: Bool {
        set {}
        get { return super.isSelected }
    }
    
    override var isHighlighted: Bool {
        set {}
        get { return super.isHighlighted }
    }
    
}

