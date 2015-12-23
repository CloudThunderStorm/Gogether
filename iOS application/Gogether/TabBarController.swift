//
//  TabBarController.swift
//  Gogether
//
//  
//

import UIKit
import MapKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var currentUser: String!
    var userDescript: String = UserData.userDescript

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.delegate = self
        
        let mainVC:ViewController = self.viewControllers?[0] as! ViewController
        mainVC.currentUser = currentUser
//        mainVC.pinArray = []
        
        let personalVC:PersonalViewController = self.viewControllers?[1] as! PersonalViewController
        personalVC.currentUser = currentUser
        personalVC.userDescript = userDescript
        personalVC.myMap = mainVC.myMap
        
        let eventVC:EventListViewController = self.viewControllers?[2] as! EventListViewController
        eventVC.currentUser = currentUser
        eventVC.myMap = mainVC.myMap
//        eventVC.pinArray = mainVC.pinArray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 {
            let mainVC:ViewController = self.viewControllers?[0] as! ViewController
            let personalVC:PersonalViewController = self.viewControllers?[1] as! PersonalViewController
            
            personalVC.currentUser = currentUser
            personalVC.myMap = mainVC.myMap
            personalVC.tableView.reloadData()
        }
        else if tabBarController.selectedIndex == 2 {
            let mainVC:ViewController = self.viewControllers?[0] as! ViewController
            let eventVC:EventListViewController = self.viewControllers?[2] as! EventListViewController
            
            eventVC.currentUser = currentUser
            eventVC.myMap = mainVC.myMap
//            eventVC.pinArray = mainVC.pinArray
            print("Should be 0: " + String(UserData.pinArray.count))
            eventVC.tableView.reloadData()
        }
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
