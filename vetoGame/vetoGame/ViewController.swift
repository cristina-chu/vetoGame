//
//  ViewController.swift
//  vetoGame
//
//  Created by Cristina on 3/23/15.
//  Copyright (c) 2015 CristinaChu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var logout: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGamesLabel: UILabel!
    
    var userID : String!
    var fbSession : FBSession!
    var total : Int = 0
    var games = NSMutableArray()
        //game = [name, id, eventType, suggestionTTL, radius, center, currentSuggestionName, eventTime, timeEnding]
    
    var currentGame : NSArray!
    
    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentGames()
    }*/
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        getCurrentGames()
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(true)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: TableView Code
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.games.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : gameCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! gameCell
        
        let row = indexPath.row
        
        cell.gameName.text = self.games[row][0] as! String
        cell.timeLeft.text = toString(self.games[row][3])
        cell.numberOfPlayers.text = "3"
        cell.currentSuggestion.text = self.games[row][6] as! String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        self.currentGame = self.games[indexPath.row] as! NSArray
    }
    //MARK:
    
    @IBAction func logginOut(sender: AnyObject) {
        fbSession.closeAndClearTokenInformation()
        self.performSegueWithIdentifier("logout", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showProfile") {
            var destViewController : profileViewController = segue.destinationViewController as! profileViewController
            
            destViewController.fbSession = FBSession.activeSession()
            destViewController.userID = self.userID
        }
        
        if (segue.identifier == "createGame") {
            var destViewController : createGameViewController = segue.destinationViewController as! createGameViewController
            
            destViewController.userID = self.userID
        }
        
        if (segue.identifier == "pastGames"){
            var destViewController : pastGamesTableViewController = segue.destinationViewController as! pastGamesTableViewController
            
            destViewController.userID = self.userID
        }
        
        if (segue.identifier == "gameScreen"){
            var destViewController : gameScreenViewController = segue.destinationViewController as! gameScreenViewController
            
            destViewController.game = self.currentGame
        }
        
        if (segue.identifier == "logout"){
            //var destViewController : facebookLoginViewController = segue.destinationViewController as facebookLoginViewController
            
            //TODO: Restart App
        }
    }
    
    //MARK: API call to get current games
    func getCurrentGames() {
        var url : String = "http://173.236.253.103:28080/game_data/get_current_games/"+self.userID
        var request : NSMutableURLRequest = NSMutableURLRequest()
        
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            
            let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error)
            
            var totalGames : Int = jsonResult!.count as Int
            
            // process jsonResult - assigning values to labels
            if (jsonResult != nil && totalGames>0) {
                self.noGamesLabel.text = ""
                
                //Going through all the games
                for (var i=0; i<totalGames; i++) {
                    //Getting each game through index
                    var result = jsonResult!.objectAtIndex(i)
                    
                    //formatting dates (eventTime, timeEnding)
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
                    
                    var eventTime = dateFormatter.dateFromString(result.objectForKey("eventTime") as! String) as NSDate!
                    var timeEnding = dateFormatter.dateFromString(result.objectForKey("timeEnding") as! String) as NSDate!
                    
                    //Getting all the information from the jsonResult
                    var name = result.objectForKey("name") as! String
                    var id = result.objectForKey("id") as! Int
                    var eventType = result.objectForKey("eventType") as! String
                    var suggestionTTL = result.objectForKey("suggestionTTL") as! Int
                    var radius = result.objectForKey("radius") as! Int
                    
                    //TODO: make sure that all games have currentSuggestion
                    var currentSuggestionName = (result.objectForKey("currentSuggestion"))!.objectForKey("name") as! String
                    
                    //needs to be change to location
                    var center = result.objectForKey("center") as! String
                    
                    var newGame = [name, id, eventType, suggestionTTL, radius, center, currentSuggestionName, eventTime, timeEnding]
                    
                    self.games.addObject(newGame)
                }
                
                self.currentGame = self.games.objectAtIndex(0) as! NSArray
                
            } else {
                // there are no current games!
                self.noGamesLabel.text = "No current games."
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

