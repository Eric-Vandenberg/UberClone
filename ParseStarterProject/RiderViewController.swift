//
//  RiderViewController.swift
//  ParseStarterProject
//
//  Created by Eric Vandenberg on 9/7/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation



class RiderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var callUberButton: UIButton!
    
    var locationManager: CLLocationManager!
    
    var riderRequestActive = false
    var driverOnTheWay = false
    
    var lat: CLLocationDegrees = 0
    var long: CLLocationDegrees = 0
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func callUber(sender: AnyObject) {
        
        if riderRequestActive == false {
        
            var riderRequest = PFObject(className:"RiderRequest")
            riderRequest["username"] = PFUser.currentUser()?.username
            riderRequest["location"] = PFGeoPoint(latitude: lat, longitude: long)

            riderRequest.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {

                    self.callUberButton.setTitle("Cancel UBER", forState: UIControlState.Normal)
                    self.displayAlert("UBER Contacted!", message: "hold tight")
                    
                } else {
                    
                    self.displayAlert("Could not find a UBER", message: "Please Try Again")
                    
                }
            }
            
            riderRequestActive = true
            
        } else {
            
            var query = PFQuery(className: "RiderRequest")
            
            query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if error == nil {
                    
                    print("Successfully retrieved: \(objects!.count)")
                    
                    if let objects = objects {
                        
                        for object in objects {
                            
                            object.deleteInBackground()
                            
                        }
                        
                    }
                    
                    self.displayAlert("Cancelled!", message: "Your UBER has been notified")
                    
                } else {
                    
                    print(error)
                    
                }
                
            })
            
            self.callUberButton.setTitle("Send for an UBER", forState: UIControlState.Normal)
            
            riderRequestActive = false
            
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() 
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var annotation = MKPointAnnotation()
        
        let location: CLLocationCoordinate2D = manager.location!.coordinate
        
        self.lat = location.latitude
        self.long = location.longitude
        
        
        var query = PFQuery(className: "RiderRequest")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                if let objects = objects as? [PFObject] {
                    
                    for object in objects {
                        
                        if let driverUsername = object["driverResponded"] {
                        
                            var deepQuery = PFQuery(className: "DriverLocation")
                            deepQuery.whereKey("username", equalTo: driverUsername)
                            deepQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                
                                if error == nil {
                                    
                                    if let objects  = objects as? [PFObject] {
                                        
                                        for object in objects {
                                            
                                            if let driverLocation = object["driverLocation"] as? PFGeoPoint {
                                                
                                                let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                                
                                                let userCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                                                
                                                let distanceMeters = userCLLocation.distanceFromLocation(driverCLLocation)
                                                
                                                let distanceMiles = distanceMeters / 1609.34
                                                
                                                let distanceRounded = Double(round(distanceMiles*10) / 10)
                                                
                                                self.callUberButton.setTitle("\(driverUsername) is \(distanceRounded) away!", forState: UIControlState.Normal)
                                                
                                                
                                                self.driverOnTheWay = true
                                                
                                                let latDelta = abs(driverLocation.latitude - location.latitude) * 2 + 0.001
                                                let longDelta = abs(driverLocation.longitude - location.longitude) * 2 + 0.001
                                                
                                                let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                                                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(latDelta, longDelta))
                                                
                                                self.map.setRegion(region, animated: true)
                                                self.map.removeAnnotations(self.map.annotations)
                                                
                                                var riderAnnotation = MKPointAnnotation()
                                                var driverAnnotation = MKPointAnnotation()
                                                
                                                let pinLocation = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                                                riderAnnotation.coordinate = pinLocation
                                                riderAnnotation.title = "Your Location"
                                                
                                                self.map.addAnnotation(riderAnnotation)
                                                
                                                let driverPinLocation = CLLocationCoordinate2DMake(driverLocation.latitude, driverLocation.longitude)
                                                driverAnnotation.coordinate = driverPinLocation
                                                driverAnnotation.title = "Driver Location"
                                                
                                                self.map.addAnnotation(driverAnnotation)
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                
                            })
                            
                            
                            
                        }
                    }
                    
                }
                
            }
            
        }
        
        
        
        
        
        
        
        if driverOnTheWay == false {
            var annotation = MKPointAnnotation()
        
            let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01))
            
            self.map.setRegion(region, animated: true)
            self.map.removeAnnotations(map.annotations)
            
            annotation.coordinate = location
            annotation.title = "Your Location"
            annotation.subtitle = "Lat: \(location.latitude) Long: \(location.longitude)"
            
            self.map.addAnnotation(annotation)
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutRider" {
            
            PFUser.logOut()
            
        }
        
    }
    
    
}
