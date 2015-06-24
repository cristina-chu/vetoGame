//
//  newSuggestionViewController.swift
//  vetoGame
//
//  Created by Cristina on 4/23/15.
//  Copyright (c) 2015 CristinaChu. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class newSuggestionListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var eventType : String!
    var radius : String!
    var center : String!
    var mapView : newSuggestionMapViewController!
    var userID = "CHUCRISTINA"
    var gameID : String!
    
    var businesses = NSMutableArray()
    //business = [name, mobileURL, rating, distance, address, ratingURL, imageURL, id]
    
    /*
    override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    }*/
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        getYelpSuggestions()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: TableView Code
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businesses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : businessCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! businessCell
        
        let row = indexPath.row
        
        if (self.businesses.count>0) {
            cell.businessButton.setTitle(self.businesses[row][0] as! String, forState: UIControlState.Normal)
            cell.distanceLabel.text = "Distance: "+(self.businesses[row][3] as! String)+" km"
            cell.ratingLabel.text = "Rating: "+toString(self.businesses[row][2])
            cell.mobileURL = self.businesses[row][1] as! String
            cell.info = self.businesses[row] as! NSArray
            cell.viewController = self
        }
        
        return cell
    }
    
    func returnSuggestion(info: NSArray) {
        var controller = self.navigationController?.viewControllers[1]
        self.navigationController?.popViewControllerAnimated(true)
        
        var prevView : gameScreenViewController = self.navigationController?.viewControllers?.last as! gameScreenViewController
        
        prevView.suggestionInfo = info
        prevView.radius = self.radius
        prevView.center = self.center
        
        prevView.mobileURL = info[1] as! String
        prevView.businessName.setTitle(info[0] as! String, forState: UIControlState.Normal)
        prevView.address.text = info[4] as! String

        //info = [name, mobileURL, rating, distance, address, ratingURL, imageURL, id]

        //send veto with new suggestion
        createNewSuggestion(self.gameID, suggestionInfo : info)
    }
    
    func createNewSuggestion(gameID: String, suggestionInfo : NSArray) {
        var url : String = "http://173.236.253.103:28080/suggestion_data/create"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "POST"
        
        //make sure all parameters exist
        if (suggestionInfo.count > 0) {
            var post = "user_id="+(self.userID as String)+"&game_id="+gameID+"&name="+(suggestionInfo[0] as! String)+"&location="+(suggestionInfo[4] as! String)+"&mobile_url="+(suggestionInfo[1] as! String)+"&image_url="+(suggestionInfo[6] as! String)+"&rating_url="+(suggestionInfo[5] as! String)
            
            let data = (post as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            
            //Sending the POST request
            request.HTTPBody = data
            
            var connection = NSURLConnection(request: request, delegate: self, startImmediately: false)
            
            connection!.start()
        }
        else {
            println("Bad suggestion")
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
    }
    
    //MARK: API call to Yelp for suggestions
    func getYelpSuggestions() {
        self.radius = mapView.radiusValue.text
        self.center = mapView.center
        
        var url : String = "http://173.236.253.103:28080/suggestion_data/yelp_suggestions_initial?center="+self.center+"&event_type="+self.eventType+"&radius="+self.radius
        var request : NSMutableURLRequest = NSMutableURLRequest()
        
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                println("Start with suggestions")
                //Get businesses
                var totalBusinessesFound = jsonResult.objectForKey("total") as! Int
                var businessesFound = jsonResult.objectForKey("businesses") as! NSArray
                
                if (totalBusinessesFound > 20) {
                    totalBusinessesFound = 20
                }
                
                //TODO: get all businesses up
                for (var i=0; i<totalBusinessesFound; i++){
                    //get each of the businesses
                    var current = businessesFound[i] as! NSDictionary
                    
                    //get business information
                    var mobileURL : String = ""
                    var imageURL : String = ""
                    var ratingURL : String = ""
                    var name : String = ""
                    var id : String = ""
                    var rating : Int = 0
                    
                    if (current.objectForKey("mobile_url") != nil) {mobileURL = current.objectForKey("mobile_url") as! String}
                    if (current.objectForKey("name") != nil) {name = current.objectForKey("name") as! String}
                    if (current.objectForKey("id") != nil) {id = current.objectForKey("id") as! String}
                    if (current.objectForKey("image_url") != nil) {imageURL = current.objectForKey("image_url") as! String}
                    if (current.objectForKey("rating_img_url") != nil) {ratingURL = current.objectForKey("rating_img_url") as! String}
                    if (current.objectForKey("rating") != nil) {rating = current.objectForKey("rating") as! Int}
                    
                    //get all the location information
                    var location = NSDictionary()
                    var coordinate = NSDictionary()
                    var displayAddress = NSArray()
                    
                    if (current.objectForKey("location") != nil) {location = current.objectForKey("location") as! NSDictionary}
                    if (location.objectForKey("coordinate") != nil) {coordinate = location.objectForKey("coordinate") as! NSDictionary}
                    if (location.objectForKey("display_address") != nil) {displayAddress = location.objectForKey("display_address") as! NSArray}
                    
                    //calculating distance between business and current location
                    var distance = Double(0.0)
                    if (coordinate.objectForKey("latitude") != nil) {
                        var locA = CLLocation(latitude: self.mapView.address.latitude, longitude: self.mapView.address.longitude)
                        var locB = CLLocation(latitude: coordinate.objectForKey("latitude") as! Double, longitude: coordinate.objectForKey("longitude") as! Double)
                    
                        var meters = locA.distanceFromLocation(locB)
                        distance = meters/1000.0
                    }
                    
                    //obtaining correct address
                    var address = ""
                    if (displayAddress.count > 0){
                        for (var x=0; x<displayAddress.count; x++){
                            address = address + (displayAddress[x] as! String)
                        }
                    }
                    
                    //adding it to the businesses array
                    var newBusiness = [name, mobileURL, rating, String(format: "%.1f",distance), address, ratingURL, imageURL, id]
                    
                    self.businesses.addObject(newBusiness)
                }
                
            println("Finished")
            } else {
                // couldn't load JSON, look at error
                println("No businesses around")
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}