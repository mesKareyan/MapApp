//
//  ViewController.swift
//  MapApp
//
//  Created by Mesrop Kareyan on 6/7/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit
import MapKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var places = PlacesManager.shared.places
    var mapCellHeight:CGFloat = 270
    var selectedAnnotation:MKPointAnnotation!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collapseButton: UIButton!
    
    var selectedPlace: PlaceInfo  = PlacesManager.shared.places.first! {
        didSet {
            let navBarHeight = self.navigationController?.navigationBar.bounds.height ?? 0;
            let offset = CGPoint(x: 0, y: self.view.frame.origin.y - navBarHeight)
            self.mainImage.image = selectedPlace.image
            self.tableView.reloadData()
            tableView.setContentOffset(offset, animated: true)
            self.tableView.rectForRow(at: IndexPath(row: 0, section: 0))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collapseButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.closeMap(cell: tableView.cellForRow(at: IndexPath(row: 0,section: 0)) as! MapCell, animated: false)
    }
    
    func showMap(cell: MapCell) {
        collapseButton.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true
        )
        mapCellHeight = view.bounds.height + 270
        let mapCellIndex = IndexPath(row: 0, section: 0)
        tableView.beginUpdates()
        tableView.endUpdates()
        self.tableView.scrollToRow(at: mapCellIndex, at: .middle, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            cell.showMap()
        }
    }
    
    func closeMap(cell:MapCell, animated: Bool = true) {
        collapseButton.isHidden = true
        mapCellHeight = 270
        self.navigationController?.setNavigationBarHidden(false, animated: true
        )
        cell.hideMap()
        //cell.hideDetails()
        let navBarHeight = self.navigationController?.navigationBar.bounds.height ?? 0;
        let offset = CGPoint(x: 0, y: self.view.frame.origin.y - navBarHeight)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.setContentOffset(offset, animated: animated)
            self.mapCellHeight = 270
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    @IBAction func collapseButtonPresed(button: UIButton) {
         self.closeMap(cell: tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! MapCell)
    }
    
    @IBAction func showPlaceDetails(_ sender: UITapGestureRecognizer) {
        collapseButton.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true
        )
        mapCellHeight = view.bounds.height + 270
        let mapCellIndex = IndexPath(row: 0, section: 0)
        tableView.beginUpdates()
        tableView.endUpdates()
        self.tableView.scrollToRow(at: mapCellIndex, at: .top, animated: true)
        let mapCell = tableView.cellForRow(at: mapCellIndex) as! MapCell
        let navBarHeight = self.navigationController?.navigationBar.bounds.height ?? 0;
        let offset = CGPoint(x: 0, y: self.view.frame.origin.y - navBarHeight)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                  mapCell.showDetails()
                    self.tableView.setContentOffset(offset, animated: true)
        }
    }
}

//MARK: TableView delegate

extension ListViewController {
    
    struct Constants {
        struct CellId {
            static let mapCell    = "mapCell"
            static let simpleCell = "simpleCell"
            static let firstCell  = "firstCell"
        }
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count + 1
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellId.mapCell) as! MapCell
            cell.configureFor(place: selectedPlace)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellId.simpleCell) as! SimpleCell
            cell.configureFor(place: places[indexPath.row - 1])
            return cell
        }
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return mapCellHeight
        default:
            return 100
        }
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
             let mapCell =  tableView.cellForRow(at: indexPath) as! MapCell
             showMap(cell: mapCell)
             self.selectedAnnotation = mapCell.map.annotations.first as? MKPointAnnotation
        default:
            self.selectedPlace = self.places[indexPath.row - 1]
            self.tableView.reloadData()
        }
    }
    
}

extension ListViewController: MKMapViewDelegate {
    // 1
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PlaceInfo {
            let identifier = "artPin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            
            view.pinTintColor = annotation.pinTintColor()
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! PlaceInfo
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}




