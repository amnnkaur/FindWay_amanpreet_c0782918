//
//  ViewController.swift
//  FindWay_amanpreet_c0782918
//
//  Created by Aman Kaur on 2020-06-09.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController{

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.initialLocation(firstLocation)
        addTapGesture()
        mapView.isZoomEnabled = false
        
       
    }
    
//    let gestureRecognizer = UITapGestureRecognizer(target: self, action:"handleTap:")
//           gestureRecognizer.delegate = self
//           mapView.addGestureRecognizer(gestureRecognizer)
//
//
//    func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
//
//        let location = gestureRecognizer.locationInView(mapView)
//        let coordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
//
//        // Add annotation:
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate
//        mapView.addAnnotation(annotation)
//    }
    
    let firstLocation = CLLocation(latitude: 43.683334, longitude: -79.766670)
    

   func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        mapView.addGestureRecognizer(tap)
   }
   
   @objc func handleTap(recognizer: UITapGestureRecognizer) {
    
    let tapLocation = recognizer.location(in: mapView)
    let tapCoordinate = mapView.convert(tapLocation, toCoordinateFrom: mapView)
       
       recognizer.numberOfTouchesRequired = 2
       
       if recognizer.state == .ended
       {
           
            let annotation = MKPointAnnotation()
            annotation.coordinate = tapCoordinate
            mapView.addAnnotation(annotation)
       }
   }
}

  extension MKMapView {
    func initialLocation(
       _ location: CLLocation,
       regionRadius: CLLocationDistance = 1000
     ) {
       let coordinateRegion = MKCoordinateRegion(
         center: location.coordinate,
         latitudinalMeters: regionRadius,
         
         longitudinalMeters: regionRadius)
       setRegion(coordinateRegion, animated: true)
     }
}
