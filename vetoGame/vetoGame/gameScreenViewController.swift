//
//  gameScreenViewController.swift
//  vetoGame
//
//  Created by Cristina on 4/21/15.
//  Copyright (c) 2015 CristinaChu. All rights reserved.
//

import Foundation
import UIKit

class gameScreenViewController : UIViewController {
    
    @IBOutlet weak var businessName: UIButton!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var suggestionTTL: UILabel!
    @IBOutlet weak var numberOfSupportersLabel: UILabel!
    @IBOutlet weak var supportButton: UIButton!
    @IBOutlet weak var vetoButton: UIButton!
    
    var game : NSArray!
        //game = [name, id, eventType, suggestionTTL, radius, center, currentSuggestionName, eventTime, timeEnding]
    var numberOfSupporters : Int = 1
    var radius = ""
    var center = ""
    var suggestionInfo : NSArray!
    var mobileURL : String = "http://www.yelp.com"
    
    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.numberOfSupportersLabel.text = "1/3"
    }*/
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        getCurrentSuggestion()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "vetoSuggestion"){
            var tabBar : UITabBarController = segue.destinationViewController as! UITabBarController
            
            var destViewMap: newSuggestionMapViewController = tabBar.viewControllers?.first as! newSuggestionMapViewController
            var destViewList: newSuggestionListViewController = tabBar.viewControllers?[1] as! newSuggestionListViewController
        
            destViewList.eventType = "dinner"//self.categoryTextField.text
        
            //sending the mapView to the listView
            destViewList.mapView = destViewMap
            
            destViewList.gameID = toString(self.game[1]) as! String
        }
    }

    @IBAction func goToWebPage(sender: UIButton) {
        let newURL = NSURL(string: self.mobileURL)
        
        UIApplication.sharedApplication().openURL(newURL!)
    }
    
    @IBAction func addSupport(sender: AnyObject) {
        self.numberOfSupporters = self.numberOfSupporters+1
        self.numberOfSupportersLabel.text = toString(self.numberOfSupporters)+"/3"
        
        //TODO: send POST request to show change
    }
    
    func getCurrentSuggestion() {
        var url : String = "http://173.236.253.103:28080/suggestion_data/current_suggestion/"+(toString(self.game[1]) as! String)
        var request : NSMutableURLRequest = NSMutableURLRequest()
        
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        print("connecting")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                //Process jsonResult - assigning values to labels
                self.businessName.setTitle(jsonResult.objectForKey("name") as! String, forState: UIControlState.Normal)
                self.address.text = jsonResult.objectForKey("location") as! String
                self.numberOfSupporters = jsonResult.objectForKey("votes") as! Int
                self.numberOfSupportersLabel.text = toString(self.numberOfSupporters)+"/3"
                self.suggestionTTL.text = toString(self.game[3]) as! String
                
                //TODO: time left
                
            } else {
                // couldn't load JSON, look at error
                println("return is null")
            }
        })
    }

}