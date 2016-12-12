//
//  DealTableViewCell.swift
//  poaster
//
//  Created by Vinod Sobale on 3/21/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit

class DealTableViewCell: UITableViewCell {
    
    @IBOutlet weak var Quantity: UILabel!
    @IBOutlet weak var PoastName: UILabel!
    @IBOutlet weak var AvailableStock: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
