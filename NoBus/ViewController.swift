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

class ViewController: UIViewController {

    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)
        textView.frame = self.view.bounds.insetBy(dx: 20, dy: 60)
        
        self.load()
        let tap = UITapGestureRecognizer(target: self, action: #selector(load))
        textView.addGestureRecognizer(tap)
    }
    
    @objc func load() {
        textView.text = "loading"
        SpotsManager.shared.getAllSpot { (spots) in
            
//            func transName(from lineID:String) -> String {
//                return stations.first(where: { $0.belongedToLine.ID == lineID })?.name ?? "lineID"+lineID
//            }
            
            DataFetcher.getStatus(for: spots) {[weak self]
                (result: Result<[String:BusStatusForStation]>) -> () in
                var text = ""
                if let statusMap = result.value {
                    text += statusMap.map({ (id, status) -> String in
                        let name = id
                        let d = status.distanceRemain
                        let t = status.estimatedRunDuration
                        let updated = Date(timeIntervalSince1970:  status.gpsUpdatedTime)
                        return String(format: "%@: %dm %.2fmins, %@", name, d, t/60, "\(updated)")
                        
                    }).joined(separator: "\n")
                }
                text += "\n\n"
                text += "\n\(result.debugDescription)"

                self?.textView.text = text
            }
            
        }
    }

}

