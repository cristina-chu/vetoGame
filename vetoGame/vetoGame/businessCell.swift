//
//  businessCell.swift
//  vetoGame
//
//  Created by Cristina on 4/20/15.
//  Copyright (c) 2015 CristinaChu. All rights reserved.
//

import Foundation
import UIKit

class businessCell: UITableViewCell {
    
    @IBOutlet weak var businessButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var addSuggestion: UIButton!
    
    var mobileURL : String!
    var info : NSArray!
        //info = [name, mobileURL, rating, distance, address, ratingURL, imageURL, id]
    var initialViewController : initialSuggestionListViewController!
    var viewController : newSuggestionListViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func goToBusinessURL(sender: UIButton) {
        let newURL = NSURL(string: self.mobileURL)
        
        UIApplication.sharedApplication().openURL(newURL!)
    }
    
    @IBAction func suggestionSelected(sender: AnyObject) {
        if (self.initialViewController != nil) {
            self.initialViewController.returnSuggestion(info)
        }
        else{
            self.viewController.returnSuggestion(info)
        }
    }
}