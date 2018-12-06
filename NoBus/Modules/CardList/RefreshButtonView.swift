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
        sv(progressView, loadingIndicator)
        loadingIndicator.centerInContainer()
        loadingIndicator.style { (loadingIndicator) in
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.isUserInteractionEnabled = false
        }
        
        progressView.fillContainer()
        progressView.style { (progressView) in
            progressView.isUserInteractionEnabled = false
        }
        
        
        self.style {
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.table.cardBorderLight
            $0.backgroundColor = UIColor.table.cardBackgroud
            $0.layer.shadowColor = UIColor.table.cardShadowHeavy
            $0.layer.shadowOpacity = 0.3
            $0.layer.shadowRadius = 10
            $0.layer.shadowOffset = CGSize(width: 0, height: 5)
            $0.backgroundColor = UIColor.table.cardBackgroud
        }
        
        self.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] _ in
            self?.viewModel?.manualTrigger.onNext(())
        }).disposed(by: bag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.width / 2
    }
    
    
    private let loadingIndicator = UIActivityIndicatorView(style: .gray)
    private let progressView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        let width: CGFloat = 10
        let dot = UIView()
        dot.backgroundColor = UIColor.table.subDescription.withAlphaComponent(0.2)
        v.sv(dot)
        dot.centerHorizontally().top(1.5).size(width)
        dot.layer.cornerRadius = width / 2
        return v
    }()

    private var viewModel: RefreshButtonViewModel.Input?
    
    private let bag = DisposeBag()
    
    private func showToLoadAnimation(duration:TimeInterval) {
        let ani = CABasicAnimation(keyPath: "transform.rotation.z")
        ani.fromValue = 0
        ani.toValue = 2 * CGFloat.pi
        ani.duration = duration
        ani.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        progressView.layer.add(ani, forKey: "rotate")
    }
}

