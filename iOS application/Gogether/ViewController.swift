//
//  ViewController.swift
//  Gogether
////

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate {
    
    let serverIP = UserData.serverIP
    
    @IBOutlet weak var myMap: MKMapView!
    
    let locationManager = CLLocationManager()
    
    
    var currentPin:EventPin!
    
    var currentUser: String!
    
//    var pinArray: [EventPin]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print(currentUser)
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.myMap.showsUserLocation = true
        
        myMap.delegate = self
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecogniser.minimumPressDuration = 1.0
        myMap.addGestureRecognizer(longPressRecogniser)
        
        addAllEvents(getJSON("http://\(serverIP):8080/findAllEvent"))
        addMyEvents(getJSON("http://\(serverIP):8080/findEventByUserMobile?userName=\(UserData.username)"))
    }
    
    func handleLongPress(getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state != .Began { return }
        
        let touchPoint = getstureRecognizer.locationInView(self.myMap)
        let touchMapCoordinate = myMap.convertPoint(touchPoint, toCoordinateFromView: myMap)
        
        let annotation = EventPin(title: "This is title", subtitle: "This is subtitle", discipline: "Sculpture", coordinate: touchMapCoordinate)

        myMap.addAnnotation(annotation)
        UserData.pinArray.append(annotation)
        myMap.showAnnotations([annotation], animated: true)
        currentPin = annotation
        addCategory(annotation)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        self.myMap.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Errors: " + error.localizedDescription)
    }
    
    var reuseId = 1
    
    func mapView(mapView: MKMapView,
        viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                //return nil so map view draws "blue dot" for standard user location
                return nil
            }
            if let annotation = annotation as? EventPin {
//                let reuseId = "pin"
                print("pinView")
                let strID = String(reuseId)
                var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(strID) as? MKPinAnnotationView
                if pinView == nil {
                    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: strID)
                    pinView!.canShowCallout = true
                    pinView!.animatesDrop = true
//                    pinView!.pinTintColor = UIColor.blueColor()
                    
//                    let gesture = UILongPressGestureRecognizer(target: self, action: "longPressed:")
//                    gesture.minimumPressDuration = 1.0
                    
                    let gesture = UITapGestureRecognizer(target: self, action: "tapped:")
                    gesture.numberOfTapsRequired = 1
                    
                    pinView?.addGestureRecognizer(gesture)
                    pinView!.pinTintColor = annotation.pinColor()
                }
                else {
                    pinView!.annotation = annotation
                }
                reuseId++
                return pinView
            }
            return nil
    }
    
    func tapped(tap : UIGestureRecognizer) {
        if (tap.state == UIGestureRecognizerState.Ended) {
            print("END")
            let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! DetailViewController
            let annoView = tap.view as? MKAnnotationView
            let pin = annoView?.annotation as? EventPin
            detailViewController.currentUser = currentUser
            detailViewController.pin = pin
            detailViewController.myMap = myMap
            addFollowers(getJSON("http://\(serverIP):8080/findUserByEventMobile?eventId=\(pin!.eventId)"), pin: pin!)
            print(pin!.title)
            self.presentViewController(detailViewController, animated:true, completion:nil)
            print("WTF")
        }
        else if (tap.state == UIGestureRecognizerState.Began) {
            print("BEGIN")
        }
    }
    
    func addCategory(annotation: MKAnnotation) {
        performSegueWithIdentifier("showPopupView", sender: annotation)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPopupView" {
            let vc = segue.destinationViewController as! PopoverViewController
            let controller = vc.popoverPresentationController
            vc.preferredContentSize = CGSizeMake(400,600)
            if controller != nil {
                controller?.delegate = self
            }
            vc.pin = currentPin
            vc.myMap = myMap
            vc.currentUser = currentUser
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getJSON(urlToRequest: String) -> NSData{
        print(urlToRequest)
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
    }
    
    func addFollowers(inputData: NSData, pin: EventPin){
        do {
            print("ahsdifhalsidhfl;aksdf")
            if let json = try NSJSONSerialization.JSONObjectWithData(inputData, options: []) as? NSArray {
                print("asjdlfkjaslkdf\(json.count)")
                for i in 0..<json.count {
//                    print(json.count)
                    let response = json[i] as! NSDictionary
                    let followerName = response["userName"] as! String
                    if pin.followers.contains(followerName) == false {
                        pin.followers.append(followerName)
                    }
                }
            } else {
                let jsonStr = NSString(data: inputData, encoding: NSUTF8StringEncoding)    // No error thrown, but not NSDictionary
                print("Error could not parse JSON: \(jsonStr)")
            }
        } catch let parseError {
            print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
            let jsonStr = NSString(data: inputData, encoding: NSUTF8StringEncoding)
            print("Error could not parse JSON: '\(jsonStr)'")
        }
    }
    
    func addAllEvents(inputData: NSData){
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(inputData, options: []) as? NSArray {
                print(json.count)
                for i in 0..<json.count {
                    let response = json[i] as? NSDictionary
                    addPin(response!)
                }
            } else {
                let jsonStr = NSString(data: inputData, encoding: NSUTF8StringEncoding)    // No error thrown, but not NSDictionary
                print("Error could not parse JSON: \(jsonStr)")
            }
        } catch let parseError {
            print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
            let jsonStr = NSString(data: inputData, encoding: NSUTF8StringEncoding)
            print("Error could not parse JSON: '\(jsonStr)'")
        }
    }
    
    func addMyEvents(inputData: NSData){
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(inputData, options: []) as? NSArray {
                print(json.count)
                for i in 0..<json.count {
                    let response = json[i] as? NSDictionary
                    addEvent(response!)
                }
            } else {
                let jsonStr = NSString(data: inputData, encoding: NSUTF8StringEncoding)    // No error thrown, but not NSDictionary
                print("Error could not parse JSON: \(jsonStr)")
            }
        } catch let parseError {
            print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
            let jsonStr = NSString(data: inputData, encoding: NSUTF8StringEncoding)
            print("Error could not parse JSON: '\(jsonStr)'")
        }
    }
    
    func addEvent(data: NSDictionary) {
        let title: String = data["title"] as! String
        let category: String = data["category"] as! String
        let descript: String = data["description"] as! String
        let latitude: Double = data["latitude"] as! Double
        let longitude: Double = data["longitude"] as! Double
        let organizerName: String = data["organizerName"] as! String
        let startTime: Double = data["startTime"] as! Double / 1000.0
        let endTime: Double = data["endTime"] as! Double / 1000.0
        let eventId: Int = data["eventId"] as! Int
        
        for aPin: EventPin in UserData.pinArray {
            if aPin.eventId == eventId {
                UserData.myEvents.append(aPin)
                return
            }
        }
        
        
        let annotation = EventPin(title: title, subtitle: category, discipline: "Sculpture", coordinate: CLLocationCoordinate2DMake(latitude, longitude))
        annotation.descript = descript
        annotation.startTime = NSDate(timeIntervalSince1970: startTime)
        annotation.endTime = NSDate(timeIntervalSince1970: endTime)
        annotation.creator = organizerName
        annotation.eventId = eventId
        
        UserData.myEvents.append(annotation)
    }
    
    func addPin(data: NSDictionary) {
        let title: String = data["title"] as! String
        let category: String = data["category"] as! String
        let descript: String = data["description"] as! String
        let latitude: Double = data["latitude"] as! Double
        let longitude: Double = data["longitude"] as! Double
        let organizerName: String = data["organizerName"] as! String
        let startTime: Double = data["startTime"] as! Double / 1000.0
        let endTime: Double = data["endTime"] as! Double / 1000.0
        let eventId: Int = data["eventId"] as! Int
        
        
        let annotation = EventPin(title: title, subtitle: category, discipline: "Sculpture", coordinate: CLLocationCoordinate2DMake(latitude, longitude))
        annotation.descript = descript
        annotation.startTime = NSDate(timeIntervalSince1970: startTime)
        annotation.endTime = NSDate(timeIntervalSince1970: endTime)
        annotation.creator = organizerName
        annotation.eventId = eventId
        myMap.addAnnotation(annotation)
        UserData.pinArray.append(annotation)
        myMap.showAnnotations([annotation], animated: true)
    }
    
    
}

