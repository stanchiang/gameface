//
//  CustomCollectionViewCell.swift
//  UICollectionView-Swift
//
//  Created by Gazolla on 22/10/14.
//  Copyright (c) 2014 Gazolla. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    let note = UITextView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        note.text = "🎉Coming Soon🎉 \n Moar Games! \n Moar Filters! \n \n send ideas, art, or just say hi \n stanchiang23@gmail.com"
        note.editable = false
        note.dataDetectorTypes = UIDataDetectorTypes.All
        note.textAlignment = .Center
        note.backgroundColor = UIColor.cyanColor()
        note.font = UIFont(name: note.font!.fontName, size: 20)
        note.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(note)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        note.centerXAnchor.constraintEqualToAnchor(self.contentView.centerXAnchor).active = true
        note.centerYAnchor.constraintEqualToAnchor(self.contentView.centerYAnchor).active = true
        note.widthAnchor.constraintEqualToConstant(200).active = true
        note.heightAnchor.constraintEqualToConstant(200).active = true
    }
}
