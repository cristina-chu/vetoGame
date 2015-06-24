//
//  gameCell.swift
//  vetoGame
//
//  Created by Cristina on 4/19/15.
//  Copyright (c) 2015 CristinaChu. All rights reserved.
//

import Foundation
import UIKit

class gameCell: UITableViewCell {

    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var currentSuggestion: UILabel!
    @IBOutlet weak var numberOfPlayers: UILabel!
    @IBOutlet weak var timeLeft: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}