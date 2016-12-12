//
//  SellerCustomerListTableViewCell.swift
//  poaster
//
//  Created by Vinod Sobale on 4/11/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit

class SellerCustomerListTableViewCell: UITableViewCell {

    @IBOutlet weak var UniqueID: UILabel!
    
    @IBOutlet weak var Email: UILabel!
    
    @IBOutlet weak var Quantity: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
