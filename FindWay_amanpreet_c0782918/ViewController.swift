//
//  ViewController.swift
//  FindWay_amanpreet_c0782918
//
//  Created by Aman Kaur on 2020-06-09.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findMyWayBtn: UIButton!
    @IBOutlet weak var segTransportType: UISegmentedControl!
    @IBOutlet weak var stepZoom: UIStepper!
    
    var oldvalue = 0.0
    var locationManager = CLLocationManager()
    var destinationCoordinates : CLLocationCoordinate2D!
    let destCoordinate = MKDirections.Request()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isZoomEnabled = false
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        tap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(tap)
       
    }
    
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        
       let mapAnnotations  = self.mapView.annotations
       self.mapView.removeAnnotations(mapAnnotations)
       let tapLocation = recognizer.location(in: mapView)
       self.destinationCoordinates = mapView.convert(tapLocation, toCoordinateFrom: mapView)
           
//           recognizer.numberOfTapsRequired = 2
           
           if recognizer.state == .ended
           {
               
                let annotation = MKPointAnnotation()
                annotation.coordinate = self.destinationCoordinates!
                annotation.title = "Your destination"
                self.mapView.addAnnotation(annotation)
           }
       }
    
    @IBAction func locationBtn(_ sender: UIButton) {
        getRoute()
    }
    
    func zoomIn() {
         var region: MKCoordinateRegion = mapView.region
                                           region.span.latitudeDelta /= 2.0
                                           region.span.longitudeDelta /= 2.0
                                           mapView.setRegion(region, animated: true)
    }
    
    func zoomOut(){
         var region: MKCoordinateRegion = mapView.region
                                            region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
                                            region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
                                            mapView.setRegion(region, animated: true)
    }
    
   
    @IBAction func stepperChanged(_ sender: UIStepper) {
//        switch stepZoom.value {
//        case 1:
//               print("max")
//               print("zoom in")
//                zoomIn()
//              case 2:
//                  print("min")
//                               //Zoom Out
//                                    var region: MKCoordinateRegion = mapView.region
//                                    region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
//                                    region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
//                                    mapView.setRegion(region, animated: true)
//                            default:
//                                break
//                            }
//
        var newvalue = stepZoom.value
        
        if(newvalue > self.oldvalue){
//            print("if")
            self.oldvalue = stepZoom.value
//            print(self.oldvalue)
            zoomIn()
            
        }else {
//            print("else")
            self.oldvalue = stepZoom.value
//            print(self.oldvalue)
        zoomOut()
            
        }
        
       
    }
    
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let userLocation = locations[0]
            
            let latitude = userLocation.coordinate.latitude
            let longitude = userLocation.coordinate.longitude
             
            let latDelta: CLLocationDegrees = 0.05
            let longDelta: CLLocationDegrees = 0.05
             
             // 3 - Creating the span, location coordinate and region
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            let customLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: customLocation, span: span)
                   
             // 4 - assign region to map
            mapView.setRegion(region, animated: true)
         }

    
    func getRoute() {
       
               let sourceCoordinate = mapView.userLocation.coordinate
               
               let source = CLLocationCoordinate2DMake(sourceCoordinate.latitude, sourceCoordinate.longitude)
               let destination = CLLocationCoordinate2DMake(self.destinationCoordinates?.latitude ?? 0, self.destinationCoordinates?.longitude ?? 0)
               
               let sourcePlacemark = MKPlacemark(coordinate: source)
               let destPlacemark = MKPlacemark(coordinate: destination)
        
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
    }
    
}


extension ViewController :MKMapViewDelegate{
    
    
   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {


        if annotation is MKUserLocation {
            return nil
        }
      
                let pinAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
                pinAnnotation.glyphTintColor = .white
                pinAnnotation.markerTintColor = .systemPink
                pinAnnotation.animatesWhenAdded = true
                return pinAnnotation

       
      
    }

func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    
    let renderer = MKPolylineRenderer(overlay: overlay)

    if (destCoordinate.transportType == .automobile){
                    renderer.strokeColor = UIColor.systemPink
                    renderer.lineWidth = 5.0
                    return renderer
    }  else if (destCoordinate.transportType == .walking){
        renderer.strokeColor = UIColor.purple
                    renderer.lineDashPattern = [2,10]
                    renderer.lineWidth = 5.0
                    return renderer
    
    }
    return renderer
}

}


//extension ViewController: CLLocationManagerDelegate {
//     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location = locations.last! as CLLocation
//        let currentLocation = location.coordinate
//        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 800, longitudinalMeters: 800)
//        mapView.setRegion(coordinateRegion, animated: true)
//        locationManager.stopUpdatingLocation()
//     }
//
//     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print(error.localizedDescription)
//     }
//}
