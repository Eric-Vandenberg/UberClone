//
//  RequestViewController.swift
//  UberClone
//
//  Created by Eric Vandenberg on 9/7/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation

class RequestViewController: UIViewController, CLLocationManagerDelegate {
    
    var requestLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var requestUsername: String = ""
    
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var pickUpLabel: UIButton!
    
    
    @IBAction func pickUp(sender: AnyObject) {
        
        var query = PFQuery(className: "RiderRequest")
        
        query.whereKey("username", equalTo: requestUsername)
        
        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if error == nil {
                
                //print("Successfully retrieved: \(objects!.count)")
                
                if let objects = objects {
                    
                    for object in objects {
                        
                        var deepQuery = PFQuery(className: "RiderRequest")
                        
                        deepQuery.getObjectInBackgroundWithId(object.objectId!!) { (object, error) -> Void in
                            
                            if error != nil {
                                
                                print(error)
                                
                            } else {
                                
                                if let object = object {
                                
                                    object["driverResponded"] = PFUser.currentUser()!.username!
                                    
                                    object.saveInBackground()
                                    
                                    let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude:self.requestLocation.longitude)
                                    
                                    CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) -> Void in
                                        
                                        if error != nil {
                                            
                                            print(error)
                                            
                                        } else {
                                            
                                            if placemarks?.count > 0 {
                                                
                                                let pm = placemarks![0] as! CLPlacemark
                                                
                                                let mkpm = MKPlacemark(placemark: pm)
                                                
                                                var mapItem = MKMapItem(placemark: mkpm)
                                                
                                                mapItem.name = self.requestUsername
                                                
                                                var launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                                                
                                                mapItem.openInMapsWithLaunchOptions(launchOptions)
                                                
                                            } else {
                                                
                                                print("problem with geocoder data")
                                            }
                                            
                                        }
                                        
                                    })
                                    
                                    
                                    
                                    
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            } else {
                
                print(error)
                
            }
            
        })
        
    }
    
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        print(requestLocation)
        print(requestUsername)
        
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpanMake(0.01, 0.01))
        
        self.map.setRegion(region, animated: true)
        self.map.removeAnnotations(map.annotations)
        
        var annotation = MKPointAnnotation()
        
        annotation.coordinate = requestLocation
        annotation.title = requestUsername
        annotation.subtitle = "Lat: \(requestLocation.latitude) Long: \(requestLocation.longitude)"
        
        self.map.addAnnotation(annotation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
