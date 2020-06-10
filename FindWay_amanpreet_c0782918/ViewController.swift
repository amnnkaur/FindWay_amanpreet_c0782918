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
      
    }
    
    let firstLocation = CLLocation(latitude: 43.683334, longitude: -79.766670)
    
   
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
