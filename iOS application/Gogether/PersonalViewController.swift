//
//  PersonalViewController.swift
//  Gogether
//
//  
//

import UIKit
import MapKit

class PersonalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var currentUser: String!
    var userDescript: String!
    var myMap: MKMapView!
    
    @IBOutlet weak var Lusername: UILabel!
    @IBOutlet weak var Ldescript: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Lusername.text = currentUser
        Ldescript.text = userDescript
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserData.myEvents.count + 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("username")! as UITableViewCell
            return cell
        }
        else if indexPath.row == 1 {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("detail")! as UITableViewCell
            cell.textLabel?.text = UserData.username
            return cell
        }
        else if indexPath.row == 2 {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("description")! as UITableViewCell
            return cell
        }
        else if indexPath.row == 3 {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("detail")! as UITableViewCell
            cell.textLabel?.text = UserData.userDescript
            return cell
        }
        else if indexPath.row == 4 {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("events")! as UITableViewCell
            return cell
        }
        else {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("detail")! as UITableViewCell
            cell.textLabel?.text = "Event: " + UserData.myEvents[indexPath.row-5].title! + "\nCategory: " + UserData.myEvents[indexPath.row-5].subtitle!
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        print(UserData.pinArray[indexPath.row].title)
        if indexPath.row > 4 {
            let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! DetailViewController
            detailViewController.currentUser = currentUser
            detailViewController.pin = UserData.myEvents[indexPath.row-5]
            detailViewController.myMap = myMap
            addFollowers(getJSON("http://\(UserData.serverIP):8080/findUserByEventMobile?eventId=\(UserData.myEvents[indexPath.row-5].eventId)"), pin: UserData.myEvents[indexPath.row-5])
            //        detailViewController.pinArray = UserData.pinArray
            self.presentViewController(detailViewController, animated:true, completion:nil)
        }
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
