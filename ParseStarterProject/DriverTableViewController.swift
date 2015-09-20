//
//  DriverTableViewController.swift
//  ParseStarterProject
//
//  Created by Eric Vandenberg on 9/7/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var usernames = [String]()
    var locations = [CLLocationCoordinate2D]()
    var distances = [CLLocationDistance]()
    
    var locationManager: CLLocationManager!
    
    var lat: CLLocationDegrees = 0
    var long: CLLocationDegrees = 0
    
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var annotation = MKPointAnnotation()
        
        let location: CLLocationCoordinate2D = manager.location!.coordinate
        
        self.lat = location.latitude
        self.long = location.longitude
        
        
        
        
        var driverQuery = PFQuery(className: "DriverLocation")
        
        driverQuery.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        
        driverQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if error == nil {
                
                //print("Successfully retrieved: \(objects!.count)")
                
                if let objects = objects {
                    
                    if objects.count > 0 {
                    
                        for object in objects {
                            
                            var deepQuery = PFQuery(className: "DriverLocation")
                            
                            deepQuery.getObjectInBackgroundWithId(object.objectId!!) { (object, error) -> Void in
                                
                                if error != nil {
                                    
                                    print(error)
                                    
                                } else if let object = object {
                                    
                                        //print("object id is \(object.objectId!)")
                                        
                                        object["driverLocation"] = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
                                        
                                        object.saveInBackground()
                                    
                                    
                                }
                                
                            }
                            
                        }
                        
                    } else {
                        
                        var driverLocation = PFObject(className: "DriverLocation")
                        
                        driverLocation["username"] = PFUser.currentUser()?.username
                        
                        driverLocation["driverLocation"] = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
                        
                        driverLocation.saveInBackground()
                        
                    }
                    
                }
                
            } else {
                
                print(error)
                
            }
            
        })
        
        
        
        
        

        
        var query = PFQuery(className: "RiderRequest")
        query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
        query.limit = 10
        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if error == nil {
                
//                print("Successfully retrieved: \(objects!.count)")
                print("\(location.latitude) and \(location.longitude)")
                
                if let objects = objects {
                    
                    self.usernames.removeAll()
                    self.locations.removeAll()
                    self.distances.removeAll()
                    
                    
                    for object in objects {
                        
                        if let username = object["username"] as? String {
                            
                            self.usernames.append(username)
                            
                        }
                        
                        if let returnedLocation = object["location"] as? PFGeoPoint {
                            
                            var requestLocation = CLLocationCoordinate2DMake(returnedLocation.latitude, returnedLocation.longitude)
                            
                            self.locations.append(requestLocation)
                            
                            let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                            
                            let driverCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

                            let distance = driverCLLocation.distanceFromLocation(requestCLLocation)
                            
                            self.distances.append(distance / 1609.34)
                            
                        }
                        
                        
                    }
                    
                    self.tableView.reloadData()
                    
                }
                
            } else {
                
                print(error)
                
            }
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        var distanceDouble = Double(distances[indexPath.row])
        
        var roundedDistance = Double(round(distanceDouble*10 / 10))

        cell.textLabel?.text = usernames[indexPath.row]
        cell.detailTextLabel?.text = String(roundedDistance) + " miles away"

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutDriver" {
            
            navigationController?.setNavigationBarHidden(true, animated: false)
            
            PFUser.logOut()
            
        } else if segue.identifier == "showViewRequests" {
            
            if let destination = segue.destinationViewController as? RequestViewController {
                
                destination.requestLocation = locations[tableView.indexPathForSelectedRow!.row]
                destination.requestUsername = usernames[tableView.indexPathForSelectedRow!.row]
                
            }
            
        }
        
    }

}
