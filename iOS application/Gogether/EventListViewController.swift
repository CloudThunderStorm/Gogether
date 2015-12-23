//
//  EventListViewController.swift
//  Gogether
//
//  
//

import UIKit
import MapKit

class EventListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
//    var pinArray: [EventPin]!
    
    var currentUser: String!
    var myMap: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let MomentaryLatitude = ("100" as NSString).doubleValue
//        let MomentaryLongitude = ("100" as NSString).doubleValue
//        let Coordinates = CLLocationCoordinate2D(latitude: MomentaryLatitude as
//            CLLocationDegrees, longitude: MomentaryLongitude as CLLocationDegrees)
//        
//        let pin1 = EventPin(title: "EventName1", subtitle: "Category1", discipline: "Sculpture", coordinate: Coordinates)
//        let pin2 = EventPin(title: "EventName2", subtitle: "Category2", discipline: "Sculpture", coordinate: Coordinates)
//        
//        pinArray.append(pin1)
//        pinArray.append(pin2)
        
//        pinArray.addObject("Event: " + pin.title! + "\nCategory: " + pin.subtitle!)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserData.pinArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        let pin: EventPin = UserData.pinArray[indexPath.row]
        cell.textLabel?.text = "Event: " + pin.title! + "\nCategory: " + pin.subtitle!
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(UserData.pinArray[indexPath.row].title)
        let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! DetailViewController
        detailViewController.currentUser = currentUser
        detailViewController.pin = UserData.pinArray[indexPath.row]
        detailViewController.myMap = myMap
        addFollowers(getJSON("http://\(UserData.serverIP):8080/findUserByEventMobile?eventId=\(UserData.pinArray[indexPath.row].eventId)"), pin: UserData.pinArray[indexPath.row])
//        detailViewController.pinArray = UserData.pinArray
        self.presentViewController(detailViewController, animated:true, completion:nil)
    }
    
    func addFollowers(inputData: NSData, pin: EventPin){
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(inputData, options: []) as? NSArray {
                print(json.count)
                for i in 0..<json.count {
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
    
    func getJSON(urlToRequest: String) -> NSData{
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
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
