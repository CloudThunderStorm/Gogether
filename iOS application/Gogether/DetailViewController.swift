//
//  DetailViewController.swift
//  Gogether
//
//  
//

import UIKit
import MapKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let serverIP = UserData.serverIP
    
//    var eventName: String!
//    var category: String!
//    var descript: String!
//    var creator: String!
//    var startTime: NSDate!
//    var endTime: NSDate!
    var currentUser: String!
    var pin:EventPin!
    var myMap: MKMapView!
//    var pinArray: [EventPin]!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var LeventName: UILabel!
    @IBOutlet weak var BJoinOrDelete: UIButton!
    
    @IBAction func Bback(sender: AnyObject) {
//        let mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainView") as! ViewController
//        self.presentViewController(mainViewController, animated:true, completion:nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func BJoinOrDeleteAction(sender: UIButton) {
        if pin.creator == currentUser {
            sendRequest("http://\(serverIP):8080/deleteEventByMobile?eventId=\(pin.eventId)")
            myMap.removeAnnotation(pin)
            if let index = UserData.pinArray.indexOf(pin) {
                UserData.pinArray.removeAtIndex(index)
                print(UserData.pinArray.count)
            }
            dismissViewControllerAnimated(true, completion: nil)
        }
        else if sender.titleLabel?.text == "Follow" {
            UserData.myEvents.append(pin)
            sendRequest("http://\(serverIP):8080/followEventMobile?userName=\(UserData.username)&eventId=\(pin.eventId)")
            sender.setTitle("Unfollow", forState: .Normal)
        }
            // unfollow
        else {
            UserData.myEvents.removeAtIndex(UserData.myEvents.indexOf(pin)!)
            sendRequest("http://\(serverIP):8080/unfollow?userName=\(UserData.username)&eventId=\(pin.eventId)")
            sender.setTitle("Follow", forState: .Normal)
        }
    }
    
    func sendRequest(urlToRequest: String) {
        let data: NSData = NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                let response = json["response"] as? String                                 // Okay, the `json` is here, let's get the value for 'success' out of it
                
                // check response
                //                    print("res in connect" + response!)
                print(response)
                //                    print("Response: \(response)")
            } else {
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)    // No error thrown, but not NSDictionary
                print("Error could not parse JSON: \(jsonStr)")
            }
        } catch let parseError {
            print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
            let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
            print("Error could not parse JSON: '\(jsonStr)'")
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        LeventName.text = pin.title
        
        
        if currentUser == pin.creator {
            BJoinOrDelete.setTitle("Delete", forState: .Normal)
        }
        else if UserData.myEvents.contains(pin){
            BJoinOrDelete.setTitle("Unfollow", forState: .Normal)
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11 + pin.followers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm a"
        
        if indexPath.row == 0 {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("catagory")! as UITableViewCell
            return cell
        }
        
        else if indexPath.row == 1 {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("detail")! as UITableViewCell
            cell.textLabel?.text = pin.subtitle
            return cell
        }
        else if indexPath.row == 2 {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("creator")! as UITableViewCell
            return cell
        }
        else if indexPath.row == 3 {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("detail")! as UITableViewCell
            cell.textLabel?.text = pin.creator
            return cell
        }
        else if indexPath.row == 4 {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("startTime")! as UITableViewCell
            
            return cell
        }
        else if indexPath.row == 5 {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("detail")! as UITableViewCell
            cell.textLabel?.text = dateFormatter.stringFromDate(pin.startTime!)
            return cell
        }
        else if indexPath.row == 6 {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("endTime")! as UITableViewCell
            
            return cell
        }
        else if indexPath.row == 7 {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("detail")! as UITableViewCell
            cell.textLabel?.text = dateFormatter.stringFromDate(pin.endTime!)
            return cell
        }
        else if indexPath.row == 8{
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("description")! as UITableViewCell
            return cell
        }
        else if indexPath.row == 9{
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("detail")! as UITableViewCell
            cell.textLabel?.text = pin.descript
            return cell
        }
        else if indexPath.row == 10{
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("followers")! as UITableViewCell
            return cell
        }
        else {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("detail")! as UITableViewCell
            cell.textLabel?.text = pin.followers[indexPath.row-11]
            return cell
        }
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
//        print(cell?.textLabel?.text)
////        print(UserData.pinArray[indexPath.row].title)
////        let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! DetailViewController
////        detailViewController.currentUser = currentUser
////        detailViewController.pin = UserData.pinArray[indexPath.row]
////        detailViewController.myMap = myMap
////        //        detailViewController.pinArray = UserData.pinArray
////        self.presentViewController(detailViewController, animated:true, completion:nil)
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
