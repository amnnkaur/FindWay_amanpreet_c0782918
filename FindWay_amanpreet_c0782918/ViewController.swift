//
//  ViewController.swift
//  FindWay_amanpreet_c0782918
//
//  Created by Aman Kaur on 2020-06-09.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findMyWayBtn: UIButton!
    @IBOutlet weak var segTransportType: UISegmentedControl!
    @IBOutlet weak var stepZoom: UIStepper!
    let locationManager: CLLocationManager = {
       let manager = CLLocationManager()
       manager.requestWhenInUseAuthorization()
       return manager
    }()
       
    var coordinate: CLLocationCoordinate2D?
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isZoomEnabled = false
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        mapView.showsCompass = true
        mapView.showsScale = true
        currentLocation()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
//        mapView.initialLocation(firstLocation)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        mapView.addGestureRecognizer(tap)
       
    }
    
    
//    let firstLocation = CLLocation(latitude: 43.683334, longitude: -79.766670)
    
    @IBAction func locationBtn(_ sender: UIButton) {
      
        getRoute()
      
    }

    @objc func handleTap(recognizer: UITapGestureRecognizer) {
     
     let mapAnnotations  = self.mapView.annotations
     self.mapView.removeAnnotations(mapAnnotations)
     let tapLocation = recognizer.location(in: mapView)
     let tapCoordinate = mapView.convert(tapLocation, toCoordinateFrom: mapView)
        
        recognizer.numberOfTapsRequired = 2
        
        if recognizer.state == .ended
        {
            
             let annotation = MKPointAnnotation()
             annotation.coordinate = tapCoordinate
             self.mapView.addAnnotation(annotation)
        }
    }
    
    func currentLocation() {
       locationManager.delegate = self
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
       if #available(iOS 11.0, *) {
          locationManager.showsBackgroundLocationIndicator = true
       } else {
        
       }
       locationManager.startUpdatingLocation()
    }

    func getRoute() {
        
        let destCoordinate = MKDirections.Request()
        let sourceCoordinate = mapView.userLocation.coordinate
        
        let source = CLLocationCoordinate2DMake(sourceCoordinate.latitude, sourceCoordinate.longitude)
        let destination = CLLocationCoordinate2DMake(coordinate?.latitude ?? 0, coordinate?.longitude ?? 0)
        
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destPlacemark = MKPlacemark(coordinate: destination)
        
        destCoordinate.source = MKMapItem(placemark: sourcePlacemark)
        destCoordinate.destination =  MKMapItem(placemark: destPlacemark)
        
        
        let direction = MKDirections(request: destCoordinate)
        direction.calculate{
            (response, error) in
               guard let locResponse = response else{
                          if let error = error{
                              print(error)
                          }
                          return
                    }
                for route in locResponse.routes{
                       self.mapView.addOverlay(route.polyline,level:.aboveRoads)
                       self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                   }
                  
               }
        
         switch segTransportType.selectedSegmentIndex {
                case 0 :
                    destCoordinate.transportType = .walking
                    for overlay in mapView.overlays{
                        mapView.removeOverlay(overlay)
                    }
                case 1 :
                    destCoordinate.transportType = .automobile
                    for overlay in mapView.overlays{
                        mapView.removeOverlay(overlay)
                        
                    }
                default:
                    break
                }
       
    }
   
}
//
//  extension MKMapView {
//    func initialLocation(
//       _ location: CLLocation,
//       regionRadius: CLLocationDistance = 1000
//     ) {
//       let coordinateRegion = MKCoordinateRegion(
//         center: location.coordinate,
//         latitudinalMeters: regionRadius,
//
//         longitudinalMeters: regionRadius)
//       setRegion(coordinateRegion, animated: true)
//     }
//}

extension ViewController: CLLocationManagerDelegate {
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 800, longitudinalMeters: 800)
        mapView.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
     }
     
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
     }
}
