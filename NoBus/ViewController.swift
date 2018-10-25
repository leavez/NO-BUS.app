//
//  ViewController.swift
//  NoBus
//
//  Created by Gao on 2018/10/24.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit
import fucking_beijing_bus_api

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
            
            for spot in spots {
                let stations = spot.stations.map({ (gs) -> [Station] in
                    gs.stationsInLines
                }).joined()
                
                let parameters = stations.map({ s in
                    (s.belongedToLine.ID, s.name, s.apiObject.index)
                })
                
                func transName(from lineID:String) -> String {
                    return stations.first(where: { $0.belongedToLine.ID == lineID })?.name ?? "lineID"+lineID
                }
                
                BeijingBusAPI.RealTime.getLineStatusForStation(parameters, completion: {[weak self] (result) in
                    var text = "\(result)\n"
                    text += "\n\n"
                    if let value = result.value {
                        text += value.map { (info) -> String in
                            let name = info.lineID.map(transName(from:))
                            let d = info.distanceRemain
                            let t = info.estimatedRunDuration
                            let updated = Date(timeIntervalSince1970:  info.gpsUpdatedTime)
                            return String(format: "%@: %dm %.2fmins, %@", name ?? "", d, t/60, "\(updated)")
                        }.joined(separator: "\n")
                        
                        text += "\n\n"
                        text += "\(value)\n"
                    }
                    self?.textView.text = text
                })
            }
            
        }
    }


}

