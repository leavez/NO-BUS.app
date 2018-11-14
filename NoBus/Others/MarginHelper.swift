//
//  MarginHelper.swift
//  NoBus
//
//  Created by Gao on 2018/11/14.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit

public struct MarginHelper {
    
    public static var margin: CGFloat {
        guard let trait = UIApplication.shared.delegate?.window??.rootViewController?.traitCollection else {
            return Constants.small
        }
        return margin(for: trait.horizontalSizeClass)
    }
    
    public static func margin(for vc: UIViewController) -> CGFloat {
        return margin(for: vc.traitCollection.horizontalSizeClass)
    }
    
    public static func margin(for sizeClass: UIUserInterfaceSizeClass) -> CGFloat{
        switch sizeClass {
        case .regular:
            return Constants.big
        default:
            return Constants.small
        }
    }
    
    private struct Constants {
        static let small: CGFloat = 30
        static let big: CGFloat = 40
    }
}
