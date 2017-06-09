//
//  PlcaeInfo.swift
//  MapApp
//
//  Created by Mesrop Kareyan on 6/7/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Contacts

class PlaceInfo : NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let details: String?
    let image: UIImage?
    
    init(
        title: String,
        details: String,
        location: CLLocationCoordinate2D,
        image: UIImage )
    {
        self.title = title
        self.subtitle = title
        self.details = details
        self.coordinate = location
        self.image = image
        super.init()
    }
    
    // MARK: - MapKit related methods
    
    // pinTintColor for disciplines: Sculpture, Plaque, Mural, Monument, other
    func pinTintColor() -> UIColor  {
            return MKPinAnnotationView.greenPinColor()
    }
    
    // annotation callout opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}

class PlacesManager {
    
    static let shared = PlacesManager()
    private(set) var places = [PlaceInfo]()
    
    init() { loadPlaces() }
    
    func loadPlaces() {
        var firstPlace: PlaceInfo!
        if let path = Bundle.main.path(
            forResource: "PlacesData",
            ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path)
                as? [String: Dictionary<String, String>] {
            for (itemName, itemValue) in dict {
                let location = itemValue["location"]!.standartLoaction!
                let image = UIImage(named: itemValue["imageName"]!)!
                let details = itemValue["details"]!
                let place = PlaceInfo(
                    title: itemName,
                    details: details,
                    location:  location,
                    image: image
                )
                if place.title == "Tatev monastery" {
                    firstPlace = place
                }
                places.append(place)
            }
        }
        let index = places.index(of: firstPlace)!
        swap(&places[index], &places[0])
    }
}

extension String {
    
    var standartLoaction: CLLocationCoordinate2D? {
        
        struct LocationValue {
            enum LocationDirection : String {
                case E
                case N
                var sign: Double {
                    switch self {
                    case .E:
                        return 1
                    case .N:
                        return 1
                    }
                }
            }
            
            let degrees: Double
            let minutes: Double?
            let seconds: Double?
            let direction: LocationDirection
            
            var doubleValue: Double {
                if minutes == nil && seconds == nil {
                    return (degrees) * direction.sign
                } else if seconds == nil {
                    return (degrees + (minutes!)/60.0) * direction.sign
                }
                 return (degrees + (minutes! + seconds!/60.0)/60.0) * direction.sign
            }
        }
        
        let locationComponents = self.components(separatedBy: " ")
        guard locationComponents.count == 2 else {
            return nil
        }
        
        let latitudeComponent  = locationComponents[0]
        var longitudeComponent = locationComponents[1]
        
        func getLocationValue(from component: String) -> LocationValue {
          
            var degrees: String
            var minutes: String! = nil
            var seconds: String! = nil
            
            let direction = LocationValue.LocationDirection(rawValue:
                String(component.characters.last!)
            )
            
            let componentString = component.substring(
                to: component.index(before: component.endIndex)
            )
        
            let compsForDegreeAndMinutes = componentString.components(separatedBy: "°")
            degrees = compsForDegreeAndMinutes.first!
            
            if compsForDegreeAndMinutes.count > 1 {
                
                let componentStringWithoutDegrees = compsForDegreeAndMinutes[1]
                let compsForMinutesAndSeconds =
                    componentStringWithoutDegrees.components(separatedBy: "′")
                if let minutesValue = compsForMinutesAndSeconds.first {
                    minutes = minutesValue
                }
                
                if compsForMinutesAndSeconds.count > 1 {
                    
                    let componenStringWithSeconds = compsForMinutesAndSeconds[1]
                    let compsForSeconds =
                        componenStringWithSeconds.components(separatedBy: "′′")
                    
                    if let secondValue = compsForSeconds.first {
                        seconds = secondValue
                    }
                }
            }

            return LocationValue(
                degrees: Double(degrees)!,
                minutes: (minutes == nil ? nil : Double(minutes)),
                seconds: (seconds == nil ? nil : Double(seconds)),
                direction: direction!
            )
            
        }
    
        let latitude  = getLocationValue(from: latitudeComponent).doubleValue
        let longitude = getLocationValue(from: longitudeComponent).doubleValue
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
    }
}
