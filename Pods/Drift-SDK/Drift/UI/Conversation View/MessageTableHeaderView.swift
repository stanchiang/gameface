//
//  MessageTableHeaderView.swift
//  Conversations
//
//  Created by Adam Gammell on 12/05/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

class MessageTableHeaderView: UIView {
    
    @IBOutlet weak var barView: GradientView!
    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.textColor = ColorPalette.navyDark
        backgroundColor = UIColor.white

        barView.colors = [UIColor.white, ColorPalette.navyMedium, ColorPalette.navyMedium, UIColor.white]

        barView.locations = [0, 0.3, 0.7, 1.0]
        barView.direction = .horizontal

    }
}
