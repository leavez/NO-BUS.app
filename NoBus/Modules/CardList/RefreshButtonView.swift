//
//  RefreshButtonView.swift
//  NoBus
//
//  Created by Gao on 2018/12/6.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import RxSwift
import Stevia

class RefreshButtonView: UIButton {
    
    
    public func bind(vm: RefreshButtonViewModel) {
        bag.insert(
        vm.output.isEnabled.bind(to: self.rx.isEnabled),
        vm.output.isReloading.bind(to: self.loadingIndicator.rx.isAnimating),
        vm.output.showNextTriggerCounterAnimation.subscribe(onNext: { [weak self] in
                self?.showToLoadAnimation(duration: $0)
            })
        )
        viewModel = vm.input
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sv(loadingIndicator)
        loadingIndicator.centerInContainer()
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.isUserInteractionEnabled = false
        
        self.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] _ in
            self?.viewModel?.manualTrigger.onNext(())
        }).disposed(by: bag)
        
        self.style {
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.table.cardBorderLight
            $0.backgroundColor = UIColor.table.cardBackgroud
            $0.layer.shadowColor = UIColor.table.cardShadowHeavy
            $0.layer.shadowOpacity = 0.3
            $0.layer.shadowRadius = 10
            $0.layer.shadowOffset = CGSize(width: 0, height: 5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.width / 2
    }
    
    private var viewModel: RefreshButtonViewModel.Input?
    
    private let loadingIndicator = UIActivityIndicatorView(style: .gray)

    private let bag = DisposeBag()
    
    private func showToLoadAnimation(duration:TimeInterval) {
        self.backgroundColor = UIColor.table.cardBackgroud
        UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
            self.backgroundColor = .red
        }, completion: nil)
    }
}

