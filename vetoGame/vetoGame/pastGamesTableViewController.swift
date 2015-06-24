//
//  pastGamesTableViewController.swift
//  vetoGame
//
//  Created by Cristina on 4/19/15.
//  Copyright (c) 2015 CristinaChu. All rights reserved.
//

import Foundation
import UIKit

class pastGamesTableViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {

    var userID : String!
    var games = NSMutableArray()
        //game = [name, id, currentSuggestionName, eventTime, timeEnding]
    
    @IBOutlet weak var noGamesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(false)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPastGames()
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
        cell.timeLeft.text = "game over"
        cell.numberOfPlayers.text = "3"
        cell.currentSuggestion.text = self.games[row][2] as! String
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    //MARK:
    
    func getPastGames() {
        var url : String = "http://173.236.253.103:28080/game_data/get_past_games/"+self.userID
        var request : NSMutableURLRequest = NSMutableURLRequest()
        
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            
            let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error)
            
            var totalGames : Int = jsonResult!.count as Int
            if (totalGames>20) {totalGames=19}
            
            // process jsonResult - assigning values to labels
            if (jsonResult != nil && totalGames>0) {
                self.noGamesLabel.text = ""
                
                //Going through all the games in jsonResult
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
                    
                    //TODO: currentSuggestionName should always be in db needs
                    var currentSuggestionName = result.objectForKey("currentSuggestion")!.objectForKey("name") as! String
                    
                    var newGame = [name, id, currentSuggestionName, eventTime, timeEnding] as NSArray
                    
                    self.games.addObject(newGame)
                }
                
            } else {
                // no current games!
                self.noGamesLabel.text = "No past games."
            }
        })
    }
    
}