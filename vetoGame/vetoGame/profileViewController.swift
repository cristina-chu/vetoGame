//
//  profileViewController.swift
//  vetoGame
//
//  Created by Cristina on 3/23/15.
//  Copyright (c) 2015 CristinaChu. All rights reserved.
//

import Foundation
import UIKit

class profileViewController : UIViewController {
    
    var userID : String!
    var fbSession : FBSession!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var numberWins: UILabel!
    @IBOutlet weak var numberPoints: UILabel!
    
    override func viewDidLoad() {
        //something
        
        getUserInfo()
    }
    
    //Getting user information through a REST API call
    func getUserInfo() {
        //var url : String = "http://173.236.253.103:28080/user_data/"+self.userID
        var url : String = "http://173.236.253.103:28080/user_data/"+self.userID
        var request : NSMutableURLRequest = NSMutableURLRequest()
        
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"

        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
    
            if (jsonResult != nil) {
                // process jsonResult - assigning values to labels
                self.userName.text = (jsonResult.objectForKey("name") as! String)
                self.numberWins.text = toString(jsonResult.objectForKey("wins") as! NSNumber)
                self.numberPoints.text = toString(jsonResult.objectForKey("points") as! NSNumber)
                
            } else {
                // couldn't load JSON, look at error
                println("return is null")
            }
        })
    }

}
