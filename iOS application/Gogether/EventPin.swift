//
//  EventPin.swift
//  Gogether
//
// 
//

import Foundation
import MapKit

class EventPin: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var descript: String
    var startTime: NSDate?
    var endTime: NSDate?
    var creator: String?
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    var eventId: Int
    var followers: [String] = []
    
//    var gesture: UILongPressGestureRecognizer!
    
    init(title: String, subtitle: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.discipline = discipline
        self.coordinate = coordinate
        self.descript = ""
        self.eventId = 1
        super.init()
//        gesture = UILongPressGestureRecognizer(target: self, action: "longPressed:")
//        gesture.minimumPressDuration = 1.0
        
        
//        var hi = UITapGestureRecognizer
//        gesture.minimumPressDuration = 3.0
    }
    
    func pinColor() -> UIColor {
        switch subtitle! {
        case "Party":
            return UIColor.redColor()
        case "Sport":
            return UIColor.blueColor()
        case "Food":
            return UIColor.yellowColor()
        case "Movie":
            return UIColor.blackColor()
        case "facebook":
            return UIColor.cyanColor()
        default:
            return UIColor.greenColor()
        }
    }
    
//    func longPressed(longPress : UIGestureRecognizer) {
//        if (longPress.state == UIGestureRecognizerState.Ended) {
//            print("END")
//            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as LoginViewController
//            self.navigationController?.pushViewController(secondViewController, animated: true)
//        }
//        else if (longPress.state == UIGestureRecognizerState.Began) {
//            print("BEGIN")
//        }
//    }
    
}