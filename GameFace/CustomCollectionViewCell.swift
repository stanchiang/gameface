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
        note.text = "🎉Coming Soon🎉 \n New Games & Filters! \n \n find me at \n stanchiang23@gmail.com"
        note.isEditable = false
        note.dataDetectorTypes = UIDataDetectorTypes.all
        note.textAlignment = .center
        note.backgroundColor = UIColor.cyan
        note.font = UIFont(name: note.font!.fontName, size: 20)
        note.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(note)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        note.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        note.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        note.widthAnchor.constraint(equalToConstant: 200).isActive = true
        note.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
}
