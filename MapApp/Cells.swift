//
//  Cells.swift
//  MapApp
//
//  Created by Mesrop Kareyan on 6/7/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit
import MapKit

class MapCell: UITableViewCell {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentContainer: UIWebView!
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    //hidden view for tap gesture
    @IBOutlet weak var tapView: UIView!
    
    var placeInfo: PlaceInfo!
    var location: CLLocationCoordinate2D!
    var regionRadius: CLLocationDistance = 1_000_000 {
        didSet {
            let coordinateRegion =
                MKCoordinateRegionMakeWithDistance(
                    location,
                    regionRadius * 2.0, regionRadius * 2.0
            )
            map?.setRegion(coordinateRegion, animated: true)
        }
    }

    func configureFor(place: PlaceInfo){
        self.map.removeAnnotations(self.map.annotations)
        self.placeInfo = place
        self.location = place.coordinate
        self.titleLabel.text = place.title
        self.contentContainer.loadHTMLString(place.details!, baseURL: nil)
        centerMapOn(location)
        self.map.isUserInteractionEnabled = false
    }
    
    func centerMapOn(_ location: CLLocationCoordinate2D) {
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location
        dropPin.title = placeInfo.title
        map.addAnnotation(dropPin)
        self.regionRadius = 50000
    }
    
    func showMap() {
        self.map.isUserInteractionEnabled = true
        self.titleLabelTopConstraint.constant = -600
        self.contentViewBottomConstraint.constant = -600
        UIView.animate(withDuration: 0.5, animations: { 
            self.map.showAnnotations(self.map.annotations, animated: true)
            self.layoutIfNeeded()
        }) { (finshed) in
            self.map.selectAnnotation(self.map.annotations.first!, animated: true)        }
    }
    
    func hideMap() {
        hideDetails()
        self.map.isUserInteractionEnabled = false
        self.titleLabelTopConstraint.constant = 0
        self.contentViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.regionRadius = 100_000
            self.layoutIfNeeded()
        }
    }
    
    func showDetails() {
        tapView.isHidden = true
        containerViewHeightConstraint.constant = bounds.height  - 20;
        UIView.animate(withDuration: 0.5) { 
            self.layoutIfNeeded()
        }
    }
    
    func hideDetails() {
        tapView.isHidden = false
        contentViewTopConstraint.constant = 0
        containerViewHeightConstraint.constant = 98
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
    }
    
}

class FirstCell: UITableViewCell {
    
    var placeInfo: PlaceInfo!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsTextContainer: UIWebView!
    
    func configureFor(place: PlaceInfo){
        self.placeInfo = place
        titleLabel.text = place.title
        detailsTextContainer.loadHTMLString(place.details!, baseURL: nil)
    }

}


class SimpleCell: UITableViewCell {
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ditailTextView: UITextView!
    
    var placeInfo: PlaceInfo!
    func configureFor(place: PlaceInfo){
        self.placeInfo = place
        titleLabel.text = placeInfo.title
        leftImageView.image = placeInfo.image
        ditailTextView.text = placeInfo.details
    }
    
    
    
}
