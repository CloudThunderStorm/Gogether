//
//  LoginViewController.swift
//  Gogether
//
// //

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    let serverIP = UserData.serverIP

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBAction func ButtonLogin(sender: UIButton) {

//        // without server
//        let tabViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TabView") as! TabBarController
//        UserData.username = usernameField.text
//        UserData.userDescript = "我是个吃货"
//        tabViewController.currentUser = usernameField.text
//        tabViewController.userDescript = "我是个吃货"
//        self.presentViewController(tabViewController, animated:true, completion:nil)
        
        // with server
        
        // get
        let userName: String = usernameField.text!
        let passWord: String = passwordField.text!
        loginGet("http://\(serverIP):8080/mobileLogin?userName=\(userName)&password=\(passWord)")
        
        
//        login { (response) -> () in
//
//            print("RES is " + response)
//            if response == "failed" {
//                self.showAlert("Login Failed", myMessage: "Wrong username/password", myAction: "OK")
//            }
//            else if response == "success" {
//                self.showAlert("Login Successfully", myMessage: "Welcome back!", myAction: "OK")
//            }
//            else {
//                self.showAlert("Unknown error", myMessage: "Something Wrong. Please try again.", myAction: "OK")
//            }
//        }
    }
    @IBAction func ButtonRegister(sender: UIButton) {
        let registerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RegisterView") as! RegisterViewController
        self.presentViewController(registerViewController, animated:true, completion:nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    func showAlert(myTitle: String, myMessage: String, myAction: String) {
        let alertController = UIAlertController(title: myTitle, message: myMessage, preferredStyle: .Alert)
        
        var defaultAction = UIAlertAction(title: myAction, style: .Default, handler: nil)
        
        if (myTitle == "Login Successfully") {
            defaultAction = UIAlertAction(title: myAction, style: .Default, handler: loginHandler)
        }
        
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func loginHandler(alert: UIAlertAction!) {
        let tabViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TabView") as! TabBarController
        UserData.username = self.usernameField.text
//        UserData.userDescript = "我是个吃货"
        tabViewController.currentUser = self.usernameField.text
//        tabViewController.userDescript = "我是个吃货"
        self.presentViewController(tabViewController, animated:true, completion:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func loginGet(urlToRequest: String) {
        print(urlToRequest)
        let data: NSData = NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                let response = json["response"] as? String                                 // Okay, the `json` is here, let's get the value for 'success' out of it
                
                // check response
                //                    print("res in connect" + response!)
                if response == "failed" {
                    
                    self.showAlert("Login Failed", myMessage: "Wrong username/password", myAction: "OK")
                    return
                }
                else if response == "success" {
                    self.showAlert("Login Successfully", myMessage: "Welcome back!", myAction: "OK")
                    UserData.userDescript = json["description"] as! String
                    return
                }
                else {
                    //                        print("RESPONSE is " + response!)
                    self.showAlert("Unknown error", myMessage: "Something Wrong. Please try again.", myAction: "OK")
                    return
                }
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
    
    func login(callback: (String) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://129.236.234.28:8080/mobileLogin")!)
        
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let jsonObject: [String: AnyObject] = [
            "userName" : usernameField.text!,
            "password" : passwordField.text!
        ]
        
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
//                    print("res in connect" + response!)
                    if response == "failed" {
                        
                        callback("failed")
                        return
                    }
                    else if response == "success" {
                        callback("success")
                        return
                    }
                    else {
//                        print("RESPONSE is " + response!)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
