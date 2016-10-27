//
//  DHCollectionTableViewController.swift
//  DHCollectionTableView
//
//  Created by 胡大函 on 14/11/3.
//  Copyright (c) 2014年 HuDahan_payMoreGainMore. All rights reserved.
//

import UIKit

let reuseTableViewCellIdentifier = "TableViewCell"
let reuseCollectionViewCellIdentifier = "CollectionViewCell"

class CollectionTableViewController: UITableViewController {
  
  var sourceArray: Array<AnyObject>!
  var contentOffsetDictionary: Dictionary<NSObject,AnyObject>!
  
  convenience init(source: Array<AnyObject>) {
    self.init()
    tableView.registerClass(CollectionTableViewCell.self, forCellReuseIdentifier: reuseTableViewCellIdentifier)
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    tableView.pagingEnabled = true
    tableView.showsVerticalScrollIndicator = false
    sourceArray = source
    contentOffsetDictionary = Dictionary<NSObject,AnyObject>()
  }
  
}
// MARK: - Table view data source
extension CollectionTableViewController {
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sourceArray.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(reuseTableViewCellIdentifier, forIndexPath: indexPath) as! CollectionTableViewCell
    return cell
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let collectionCell = cell as! CollectionTableViewCell
    collectionCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, index: indexPath.row)
    
    let index = collectionCell.collectionView.tag
    let value = contentOffsetDictionary[index]
    let horizontalOffset = CGFloat(value != nil ? value!.floatValue : 0)
    collectionCell.collectionView.setContentOffset(CGPointMake(horizontalOffset, 0), animated: false)
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UIScreen.mainScreen().bounds.height
  }
}
// MARK: - Collection View Data source and Delegate
extension CollectionTableViewController:UICollectionViewDataSource,UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let collectionViewArray = sourceArray[collectionView.tag] as! Array<AnyObject>
    return collectionViewArray.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCollectionViewCellIdentifier, forIndexPath: indexPath)
    
    let collectionViewArray = sourceArray[collectionView.tag] as! Array<AnyObject>
    cell.backgroundColor = collectionViewArray[indexPath.item] as? UIColor
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let itemColor: UIColor = (sourceArray[collectionView.tag] as! Array<AnyObject>)[indexPath.item] as! UIColor

    let alert = UIAlertController(title: "[\(collectionView.tag)] ", message: "[\((indexPath as NSIndexPath).item)]", preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
    let v: UIView = UIView(frame: CGRectMake(10, 20, 50, 50))
    v.backgroundColor = itemColor
    alert.view.addSubview(v)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    if !(scrollView is UICollectionView) {
      return
    }
    let horizontalOffset = scrollView.contentOffset.x
    let collectionView = scrollView as! UICollectionView
    contentOffsetDictionary[collectionView.tag] = horizontalOffset
  }
}
