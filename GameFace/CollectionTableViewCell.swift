//
//  DHCollectionTableViewCell.swift
//  DHCollectionTableView
//
//  Created by 胡大函 on 14/11/3.
//  Copyright (c) 2014年 HuDahan_payMoreGainMore. All rights reserved.
//

import UIKit

class IndexedCollectionView: UICollectionView {
  
  var indexPath: NSIndexPath!
  
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

let collectionViewCellIdentifier: NSString = "CollectionViewCell"
class CollectionTableViewCell: UITableViewCell {
  
  var collectionView: IndexedCollectionView!
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsetsZero
    layout.minimumLineSpacing = 0
    layout.itemSize = UIScreen.mainScreen().bounds.size
    layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    self.collectionView = IndexedCollectionView(frame: CGRectZero, collectionViewLayout: layout)
    self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: collectionViewCellIdentifier as String)
    self.collectionView.backgroundColor = UIColor.lightGrayColor()
    self.collectionView.showsHorizontalScrollIndicator = false
    self.collectionView.pagingEnabled = true
    
    self.contentView.addSubview(self.collectionView)
    self.layoutMargins = UIEdgeInsetsZero
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.collectionView.frame = UIScreen.mainScreen().bounds
  }
  
  func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: protocol<UICollectionViewDelegate,UICollectionViewDataSource>, index: NSInteger) {
    self.collectionView.dataSource = delegate
    self.collectionView.delegate = delegate
    self.collectionView.tag = index
    self.collectionView.reloadData()
  }
  
  func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: protocol<UICollectionViewDelegate,UICollectionViewDataSource>, indexPath: NSIndexPath) {
    self.collectionView.dataSource = delegate
    self.collectionView.delegate = delegate
    self.collectionView.indexPath = indexPath
    self.collectionView.tag = indexPath.section
    self.collectionView.reloadData()
  }
}
