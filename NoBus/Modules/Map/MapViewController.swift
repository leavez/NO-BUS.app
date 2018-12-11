//
//  MapViewController.swift
//  NoBus
//
//  Created by Gao on 2018/12/10.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import Stevia
import fucking_beijing_bus_api

class MapViewController: UIViewController {
    
    let mapView = MKMapView(frame: .zero)
    let viewModel: MapViewModel
    
    init(lines: [LineDetail], referenceStation: LineDetail.Station? = nil) {
        viewModel = MapViewModel(lines: lines, referenceStation: referenceStation)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sv(mapView)
        mapView.fillContainer()
        
        mapView.delegate = self
        mapView.isPitchEnabled = false
        
        self.bindViewModel(viewModel)
        self.showLineElementsInMap()
    }
    
    func bindViewModel(_ vm: MapViewModel) {
        
        // draw liens
        vm.output.staticLines
        .subscribe(onNext: {[unowned self] lines in
            for line in lines {
                // line
                let coors = line.parsedLineCoordinates
                let overlay = BusPloyline(coordinates: coors, count: coors.count)
                self.mapView.addOverlay(overlay)
                // stops
                line.stations.forEach({ (s) in
                    let stop = BusStopOverlay(center: s.location.CLCoordinate2D, radius: 15)
                    self.mapView.addOverlay(stop)
                })
            }
        }).disposed(by: bag)
        
        vm.output.referenceStation
        .subscribe(onNext: {[unowned self] stationCoordinate in
            if let stationCoordinate = stationCoordinate {
                let overlay = BusStopReferencedOverlay(center: stationCoordinate, radius: 30)
                self.mapView.addOverlay(overlay)
            }
        }).disposed(by: bag)
        
        // zoom to properate region
        vm.output.center.subscribe(onNext: {
            [unowned self] location in
            if let cor = location {
                let region = MKCoordinateRegion(
                    center: cor,
                    latitudinalMeters: 1200,
                    longitudinalMeters: 1200)
                self.mapView.setRegion(region, animated: true)
            }
        }).disposed(by: bag)
        
        
        vm.output.status.subscribe(onNext: { status in
            
        }).disposed(by: bag)
        
        
    }
    
    
    func showLineElementsInMap() {
        
    }
    
    private let bag = DisposeBag()
}

class BusPloyline: MKPolyline {}
class BusStopOverlay: MKCircle {}
class BusStopReferencedOverlay: MKCircle {}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case let o as BusPloyline:
            let render = MKPolylineRenderer(polyline: o)
            render.strokeColor = UIColor.table.busRoute
            render.lineWidth = 4
            render.lineDashPattern = [2,6]
            return render
        case let o as BusStopOverlay:
            let render = MKCircleRenderer(circle: o)
            render.fillColor = UIColor.table.busStop
            return render
        case let o as BusStopReferencedOverlay:
            let render = MKCircleRenderer(circle: o)
            render.strokeColor = UIColor.white
            render.lineWidth = 3
            render.lineCap = .square
            render.lineDashPattern = [2,4]
            return render
        default:
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
