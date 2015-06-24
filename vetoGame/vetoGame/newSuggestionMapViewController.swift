//
//  newSuggestionMapViewController.swift
//  vetoGame
//
//  Created by Cristina on 4/23/15.
//  Copyright (c) 2015 CristinaChu. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class newSuggestionMapViewController : UIViewController , CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var radiusValue: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    var center : String!
    var address : CLLocationCoordinate2D!
    
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        //self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()){
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]) {
        var locValue : CLLocationCoordinate2D = manager.location.coordinate
        self.address = locValue
        
        self.geoCoder.reverseGeocodeLocation(CLLocation(latitude: locValue.latitude, longitude: locValue.longitude), completionHandler: { (placemarks, error) -> Void in
            if (placemarks.count>0) {
                self.locationManager.stopUpdatingLocation()
                let placemark = placemarks[0]
                
                let locality = (placemark.locality != nil) ? placemark.locality : ""
                let postalCode = (placemark.postalCode != nil) ? placemark.postalCode : ""
                let administrativeArea = (placemark.administrativeArea != nil) ? placemark.administrativeArea : ""
                let country = (placemark.country != nil) ? placemark.country : ""
                
                self.center = locality
                self.locationName.text = locality+", "+administrativeArea+", "+country
            }
        })
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        self.map.addAnnotation(annotation)
        
        let theSpan : MKCoordinateSpan = MKCoordinateSpanMake(Double(self.radiusValue.text!.toInt()!)*0.01 , Double(self.radiusValue.text!.toInt()!)*0.01)
        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(locValue, theSpan)
        self.map.setRegion(theRegion, animated: true)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    
    
    @IBAction func changingRadiusValue(sender: UISlider) {
        var currentValue = Int(sender.value)
        
        self.radiusValue.text = toString(currentValue)
        
        let theSpan : MKCoordinateSpan = MKCoordinateSpanMake(Double(currentValue)*0.01 , Double(currentValue)*0.01)
        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(self.address, theSpan)
        self.map.setRegion(theRegion, animated: true)
    }
    
}