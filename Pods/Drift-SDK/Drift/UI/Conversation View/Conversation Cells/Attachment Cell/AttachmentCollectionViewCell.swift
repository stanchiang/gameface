//
//  AttachmentCollectionViewCell.swift
//  Drift
//
//  Created by Brian McDonald on 20/06/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

class AttachmentCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var attacmentImageView: UIImageView!
    @IBOutlet weak var fileExtensionLabel: UILabel!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = ColorPalette.attachmentBackgroundColor
        
        fileNameLabel.textColor = UIColor.black
        sizeLabel.textColor = UIColor.gray
    }
}
