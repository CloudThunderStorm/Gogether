//
//  PopoverViewController.swift
//  Gogether
//
//  //

import UIKit
import MapKit

class PopoverViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate, MKMapViewDelegate {
    let serverIP = UserData.serverIP
    
    var categories = ["Party", "Sport", "Food", "Movie"]
    var currentCategory: String!
    var currentEventName: String!
    var currentDescription: String!
    var currentUser: String!
    var pin:EventPin!
    var myMap: MKMapView!
    @IBOutlet weak var TFeventName: UITextField!
    @IBOutlet weak var TVdescription: UITextView!
    @IBOutlet weak var DatePickerStart: UIDatePicker!
    @IBOutlet weak var DatePickerEnd: UIDatePicker!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func creatNewEvent(sender: UIButton) {
//        currentEventName = TFeventName.text
//        currentDescription = TVdescription.text
        pin.title = TFeventName.text
        pin.subtitle = currentCategory
        pin.descript = TVdescription.text
        pin.startTime = DatePickerStart.date
        pin.endTime = DatePickerEnd.date
        pin.creator = currentUser
        pin.followers.append(UserData.username)
        
        addEvent(pin)
        UserData.myEvents.append(pin)
        
        let test: MKPinAnnotationView = myMap.viewForAnnotation(pin) as! MKPinAnnotationView
        test.pinTintColor = pin.pinColor()

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelNewEvent(sender: UIButton) {
        if let index = UserData.pinArray.indexOf(pin) {
            UserData.pinArray.removeAtIndex(index)
        }
        myMap.removeAnnotation(pin)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        currentCategory = categories[0]
        TFeventName.delegate = self
        TVdescription.delegate = self
        scrollView.contentSize.height = 500
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentCategory = categories[row]
        print(currentCategory)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        scrollView.contentSize.height = scrollView.contentSize.height + 150
        scrollView.setContentOffset(CGPointMake(0.0, 150.0), animated: true)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        scrollView.contentSize.height = scrollView.contentSize.height - 150
    }
    
    func addEvent(pin: EventPin) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://\(serverIP):8080/addEventByMobile")!)
        
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let jsonObject: [String: AnyObject] = [
            "title" : pin.title!,
            "eventId" : 1,
            "description" : pin.descript,
            "longitude" : pin.coordinate.longitude,
            "latitude" : pin.coordinate.latitude,
            "organizerName" : pin.creator!,
            "startTime" : NSNumber(longLong:Int64(((pin.startTime?.timeIntervalSince1970)!)*1000.0)),
            "endTime" : NSNumber(longLong:Int64(((pin.endTime?.timeIntervalSince1970)!)*1000.0)),
            "category" : pin.subtitle!,
            "status" : ""
        ]
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonObject, options: [])
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            }
            
            print("response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            pin.eventId = Int(responseString as! String)!
            print("responseString = \(responseString)")
        }
        
        task.resume()
    }
    
//    var reuseId = 1
//    
//    func mapView(mapView: MKMapView,
//        viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//            if annotation is MKUserLocation {
//                //return nil so map view draws "blue dot" for standard user location
//                return nil
//            }
//            if let annotation = annotation as? EventPin {
//                //                let reuseId = "pin"
//                print("pinView")
//                let strID = String(reuseId)
//                var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(strID) as? MKPinAnnotationView
//                if pinView == nil {
//                    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: strID)
//                    pinView!.canShowCallout = true
//                    pinView!.animatesDrop = true
//                    //                    pinView!.pinTintColor = UIColor.blueColor()
//                    
//                    //                    let gesture = UILongPressGestureRecognizer(target: self, action: "longPressed:")
//                    //                    gesture.minimumPressDuration = 1.0
//                    
//                    let gesture = UITapGestureRecognizer(target: self, action: "tapped:")
//                    gesture.numberOfTapsRequired = 1
//                    
//                    pinView?.addGestureRecognizer(gesture)
//                    pinView!.pinTintColor = annotation.pinColor()
//                }
//                else {
//                    pinView!.annotation = annotation
//                }
//                reuseId++
//                return pinView
//            }
//            return nil
//    }
//    
//    func tapped(tap : UIGestureRecognizer) {
//        if (tap.state == UIGestureRecognizerState.Ended) {
//            print("END")
//            let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! DetailViewController
//            let annoView = tap.view as? MKAnnotationView
//            let pin = annoView?.annotation as? EventPin
//            detailViewController.currentUser = currentUser
//            detailViewController.pin = pin
//            detailViewController.myMap = myMap
//            addFollowers(getJSON("http://\(serverIP):8080/findUserByEventMobile?eventId=\(pin!.eventId)"), pin: pin!)
//            print(pin!.title)
//            self.presentViewController(detailViewController, animated:true, completion:nil)
//            print("WTF")
//        }
//        else if (tap.state == UIGestureRecognizerState.Began) {
//            print("BEGIN")
//        }
//    }
//    
//    func getJSON(urlToRequest: String) -> NSData{
//        print(urlToRequest)
//        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
//    }
//    
//    func addFollowers(inputData: NSData, pin: EventPin){
//        do {
//            print("ahsdifhalsidhfl;aksdf")
//            if let json = try NSJSONSerialization.JSONObjectWithData(inputData, options: []) as? NSArray {
//                print("asjdlfkjaslkdf\(json.count)")
//                for i in 0..<json.count {
//                    //                    print(json.count)
//                    let response = json[i] as! NSDictionary
//                    let followerName = response["userName"] as! String
//                    if pin.followers.contains(followerName) == false {
//                        pin.followers.append(followerName)
//                    }
//                }
//            } else {
//                let jsonStr = NSString(data: inputData, encoding: NSUTF8StringEncoding)    // No error thrown, but not NSDictionary
//                print("Error could not parse JSON: \(jsonStr)")
//            }
//        } catch let parseError {
//            print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
//            let jsonStr = NSString(data: inputData, encoding: NSUTF8StringEncoding)
//            print("Error could not parse JSON: '\(jsonStr)'")
//        }
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
