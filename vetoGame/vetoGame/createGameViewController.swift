//
//  createGameViewController.swift
//  vetoGame
//
//  Created by Cristina on 3/23/15.
//  Copyright (c) 2015 CristinaChu. All rights reserved.
//

import Foundation
import UIKit

class createGameViewController : UIViewController {
    
    let currentDate = NSDate()
    var userID: String!
    var radius : String!
    var center : String!
    var friends = [NSArray]()
    var suggestionInfo = NSArray()
    var gameID : String = ""
    
    //used for the POST request
    var eventTimePOST : String = ""
    var gameTimeEndPOST : String = ""
    
    //variables on the UI
    @IBOutlet weak var gameNameTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var selectPlayers: UIButton!
    @IBOutlet weak var eventDate: UITextField!
    @IBOutlet weak var gameEndTime: UITextField!
    @IBOutlet weak var initialSuggestionButton: UIButton!
    @IBOutlet weak var createGameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func selectEventDate(sender: UITextField) {
        var datePickerView  : UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        sender.inputView = datePickerView
        datePickerView.minimumDate = self.currentDate
        datePickerView.addTarget(self, action: Selector("handleDateStart:"), forControlEvents: UIControlEvents.ValueChanged)
        
        //TODO: make start date only possible for up to a certain amount of days (datePickerView.maximumDate)
    }
    
    @IBAction func selectGameEndTime(sender: UITextField) {
        var datePickerView  : UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleDateEnd:"), forControlEvents: UIControlEvents.ValueChanged)
        
        //TODO: make ending date only possible for later dates and up to a certain amount of days
        datePickerView.minimumDate = self.currentDate
    }
    
    func handleDateStart(sender: UIDatePicker) {
        var timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = .LongStyle
        timeFormatter.timeStyle = .ShortStyle
        self.eventDate.text = timeFormatter.stringFromDate(sender.date)
        
        timeFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
        self.eventTimePOST = timeFormatter.stringFromDate(sender.date)
    }

    func handleDateEnd(sender: UIDatePicker) {
        var timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = .LongStyle
        timeFormatter.timeStyle = .ShortStyle
        gameEndTime.text = timeFormatter.stringFromDate(sender.date)
        
        timeFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
        self.gameTimeEndPOST = timeFormatter.stringFromDate(sender.date)
    }
    
    @IBAction func createGame(sender: AnyObject) {
        //call database and create a new game
        println("creating game")
        createGameDB()
        println(self.gameID)
        
        //get the gameID and send the new suggestion and add the players
        //println("creating suggestion")
        //createNewSuggestion(self.gameID)
        
        //println("creating players")
        //addPlayers(self.gameID)
        
        //Going back to the Home page
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches as Set<NSObject>, withEvent: event)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "initialSuggestion") {
            var tabBar : UITabBarController = segue.destinationViewController as! UITabBarController
    
            var destViewMap: initialSuggestionMapViewController = tabBar.viewControllers?.first as! initialSuggestionMapViewController
            var destViewList: initialSuggestionListViewController = tabBar.viewControllers?[1] as! initialSuggestionListViewController
            
            destViewList.eventType = self.categoryTextField.text
            
            //sending the mapView to the listView
            destViewList.mapView = destViewMap
        }
        
        if (segue.identifier == "selectPlayers"){
            var destView : selectPlayersViewController = segue.destinationViewController as! selectPlayersViewController
        }
    }
    
    //Sending all info to database
    func createGameDB() {
        var url : String = "http://173.236.253.103:28080/game_data/create"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "POST"
        
        //Creating the POST parameters
        //check that all information is there
        var suggestionExists : Bool = self.suggestionInfo.count > 0
        var nameExists : Bool = self.gameNameTextField.text != ""
        var categoryExists : Bool = self.categoryTextField.text != ""
        var eventTimeExists : Bool = self.eventTimePOST != ""
        var gameTimeExists : Bool = self.gameTimeEndPOST != ""
        
        if (suggestionExists && nameExists && categoryExists && eventTimeExists && gameTimeExists){
            //TODO: suggestionTTL
            var postParams1 = "user_id="+self.userID+"&event_type="+self.categoryTextField.text+"&game_name="+self.gameNameTextField.text+"&event_time="+(self.eventTimePOST as String)
            var postParams2 = "&time_ending="+(self.gameTimeEndPOST as String)+"&center="+(self.center as String)+"&radius="+(self.radius as String)+"&suggestion_ttl=180"
            
            let postParams = postParams1 + postParams2
            let data = (postParams as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            
            //Sending the POST request
            request.HTTPBody = data
            
            var connection = NSURLConnection(request: request, delegate: self, startImmediately: false)
            
            connection!.start()
        }
        else {
            println("Missing information")
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        var err : NSErrorPointer = nil
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: err) as! NSDictionary
        
        if (self.gameID == ""){
            self.gameID = toString(jsonResult.objectForKey("id") as! Int)
            println(self.gameID)
            
            createNewSuggestion(self.gameID)
            
            addPlayers(self.gameID)
        }
    }

    func createNewSuggestion(gameID: String) {
        var url : String = "http://173.236.253.103:28080/suggestion_data/create"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "POST"

        //make sure all parameters exist
        if (self.suggestionInfo.count > 0) {
            var post = "user_id="+(self.userID as String)+"&game_id="+gameID+"&name="+(self.suggestionInfo[0] as! String)+"&location="+(self.suggestionInfo[4] as! String)+"&mobile_url="+(self.suggestionInfo[1] as! String)+"&image_url="+(self.suggestionInfo[6] as! String)+"&rating_url="+(self.suggestionInfo[5] as! String)

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
    
    func addPlayers(gameID: String) {
        //make sure all parameters exist
        if (self.friends.count > 0) {
            for (var i=0; i<self.friends.count; i++){
                var url : String = "http://173.236.253.103:28080/game_data/add_user_to_game/"
                var request : NSMutableURLRequest = NSMutableURLRequest()
                request.URL = NSURL(string: url)
                request.HTTPMethod = "POST"
                
                var user_id : String = self.friends[i][0] as! String
                var post = "user_id="+user_id+"&game_id="+gameID
            
                var data = (post as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            
                //Sending the POST request
                request.HTTPBody = data
            
                var connection = NSURLConnection(request: request, delegate: self, startImmediately: false)
            
                connection!.start()
            }
        }
        else {
            println("No players to add.")
        }
    }
}
