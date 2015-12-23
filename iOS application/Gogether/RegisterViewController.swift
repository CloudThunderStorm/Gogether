//
//  RegisterViewController.swift
//  Gogether
//
//  
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    let serverIP = UserData.serverIP

    @IBOutlet weak var FieldUsername: UITextField!
    @IBOutlet weak var FieldPassword: UITextField!
    @IBOutlet weak var FieldRePassword: UITextField!
    @IBOutlet weak var FieldDescription: UITextField!
    
    var jsonObject: [String: AnyObject]!
    
    func showAlert(myTitle: String, myMessage: String, myAction: String) {
        let alertController = UIAlertController(title: myTitle, message: myMessage, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: myAction, style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func register(callback: (String) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://\(serverIP):8080/addUser")!)
        
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonObject, options: [])
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard data != nil else {
                print("no data found: \(error)")
                callback("No data")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    let response = json["response"] as? String                                 // Okay, the `json` is here, let's get the value for 'success' out of it
                    
                    // check response
                    if response == "failed" {
                        
                        callback("failed")
                        return
                    }
                    else if response == "success" {
                        callback("success")
                        return
                    }
                    else {
                        callback("unknown")
                        return
                    }
//                    print("Response: \(response)")
                } else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)    // No error thrown, but not NSDictionary
                    print("Error could not parse JSON: \(jsonStr)")
                }
            } catch let parseError {
                print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
            }
        }
        
        task.resume()
    }
    
    
    @IBAction func ButtonRegister(sender: UIButton) {
        
        if FieldPassword.text != FieldRePassword.text {
            showAlert("Wrong password", myMessage: "Passwords don't match", myAction: "OK")
//            let alertController = UIAlertController(title: "Wrong password", message: "Passwords don't match", preferredStyle: .Alert)
//            
//            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
//            alertController.addAction(defaultAction)
//            
//            presentViewController(alertController, animated: true, completion: nil)
//            
            FieldPassword.text = ""
            FieldRePassword.text = ""
            return
        }
        
        jsonObject = [
            "name" : FieldUsername.text!,
            "userId" : 1,
            "description" : FieldDescription.text!,
            "bioImageURL" : "bioImage",
            "password" : FieldPassword.text!
        ]
        
        print("BEFORE")
        register { (response) -> () in
//            self.FieldUsername.text = ""
//            self.FieldPassword.text = ""
//            self.FieldRePassword.text = ""
//            self.FieldDescription.text = ""
            print("RES is " + response)
            if response == "failed" {
                self.showAlert("Wrong username", myMessage: "Username is already existed", myAction: "OK")
            }
            else if response == "success" {
                self.showAlert("Success", myMessage: "User registration is successful", myAction: "OK")
            }
            else {
                self.showAlert("Unknown error", myMessage: "Something Wrong. Please try again.", myAction: "OK")
            }
        }
        print("AFTER")
        
//        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func ButtonBack(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        FieldUsername.delegate = self
        FieldPassword.delegate = self
        FieldRePassword.delegate = self
        FieldDescription.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
