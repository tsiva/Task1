//
//  ListViewCell.swift
//  ListTask
//
//  Created by Siva Kumar Reddy Thimmareddy on 11/09/19.
//  Copyright © 2019 Siva Kumar Reddy Thimmareddy. All rights reserved.
//

import UIKit

class ListViewCell: UITableViewCell {

    @IBOutlet weak var postTitleLbl: UILabel!
    @IBOutlet weak var postDateLbl: UILabel!
    @IBOutlet weak var actionSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
