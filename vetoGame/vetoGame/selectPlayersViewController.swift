//
//  inviteFriendsViewController.swift
//  vetoGame
//
//  Created by Cristina on 4/9/15.
//  Copyright (c) 2015 CristinaChu. All rights reserved.
//

import Foundation
import UIKit

class selectPlayersViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {

    let friends : [NSArray] = [["ABMURTHY", "Abhijit Murthy"], ["EKIM305", "Eunki Kim"], ["IAN1639", "Ian Stainbrook"], ["VIRAL9793", "Viral Patel"]]
    var gameID : String!
    var selectedFriends = [NSArray]()
    
    @IBOutlet weak var addPlayersButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
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
        return self.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : friendCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! friendCell
        
        let row = indexPath.row
        
        cell.nameLabel.text = self.friends[row][1] as! String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        
        //TODO: unselect
        selectedCell?.selected = true
        self.selectedFriends.append(self.friends[indexPath.row])
    }
    //MARK:
    
    //TODO: get friends directly from Facebook
    func getFacebookFriends () {
        var friendsRequest: FBRequest = FBRequest.requestForMyFriends()
        /*
        friendsRequest.startWithCompletionHandler{(connection:FBRequestConnection!, result:AnyObject, error:NSError!) -> Void in
            var resultdict = result as NSDictionary
            println("Result Dict: \(resultdict)")
            
            var data : NSArray = resultdict.objectForKey("data") as NSArray
            println(data)
            
            for i in 0...data.count {
                let valueDict : NSDictionary = data[i] as NSDictionary
                let id = valueDict.objectForKey("id") as String
                println("the id value is \(id)")
            }
            
            var friends = resultdict.objectForKey("data") as NSArray
            println("Found \(friends.count) friends")
        }
        */
    }
    
    @IBAction func sendPlayersBack(sender: AnyObject) {
        //send info back
        self.navigationController?.popViewControllerAnimated(true)
        
        var prevView : createGameViewController = self.navigationController?.viewControllers?.last as! createGameViewController
        
        prevView.friends = self.selectedFriends
    }
    
    func addFriendsToGame() {
        
        ///http://173.236.253.103:28080/game_data/add_user_to_game/
        //userid, gameid
    }
    
}