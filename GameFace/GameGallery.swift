//
//  GameGallery.swift
//  GameFace
//
//  Created by Stanley Chiang on 10/14/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import SpriteKit

class GameGallery: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UIKitDelegate {
    lazy var collectionView:UICollectionView = {
        var cv = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.bounces = true
        cv.alwaysBounceHorizontal = true
        cv.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        cv.registerClass(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        cv.backgroundColor = UIColor.clearColor()
        cv.pagingEnabled = true
        return cv
    }()
    
    lazy var flowLayout:UICollectionViewFlowLayout = {
        var flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .Horizontal
        return flow
    }()
    
    lazy var items:NSMutableArray = {
        var it:NSMutableArray = NSMutableArray()
        return it
    }()
    
    let cameraHandler = CameraHandler()
    var cameraImage:UIImageView!
    
    var gameView:UIView!
    var managerView:UIView!
    
    var scene:GameScene!
    var manager:GameManager!
    
    var shape: CAShapeLayer!
    var mouth:[CGPoint]!
    
    var debugView:DebugView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        cameraHandler.openSession()
        setupCameraImage()
        
        debugView = DebugView(frame: self.view.frame)
        
        
        self.items.addObjectsFromArray(["Card #1"])
        self.items.addObjectsFromArray(["Card #2"])
        self.view.addSubview(self.collectionView)
    }
    
    func setupCameraImage(){
        cameraImage = UIImageView()
        cameraImage.frame = self.view.frame
        self.view.addSubview(cameraImage)
        cameraImage.transform = CGAffineTransformScale(self.cameraImage.transform, -1, 1)
    }
    
    
    //MARK: Collection View Delegate
    override func viewDidLayoutSubviews() {
        collectionView.layoutIfNeeded()
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        
        let width:CGFloat = self.view.bounds.size.width
        let height:CGFloat = self.view.bounds.size.height
        
        return CGSizeMake(width, height)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.flowLayout.invalidateLayout()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CustomCollectionViewCell
        
        if indexPath.row == 0 {
            cell.contentView.addSubview(debugView)
            
        }
        
        if indexPath.row == 1 {
            cell.contentView.addSubview(setupGameLayer())
            cell.contentView.addSubview(setupGameManager())
            
            scene.sceneDelegate = manager
            scene.gameVarDelegate = debugView
            manager.managerDelegate = scene
            manager.uikitDelegate = self
            
            (UIApplication.sharedApplication().delegate as! AppDelegate).gameState = .preGame
            self.manager.instructions.text = "Open Mouth to Start Game"
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        resetGame()
//        if (UIApplication.sharedApplication().delegate as! AppDelegate).gameState == .inPlay {
//            scene.updatePauseHandler(to: .paused)
//        }
    }
    
    //MARK: Basketball SpriteKit methods
    func setupGameLayer() -> UIView {
        gameView = UIView(frame: self.view.frame)
        gameView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        gameView.transform = CGAffineTransformScale(gameView.transform, 1, -1)

        let skView = SKView(frame: view.frame)
        skView.allowsTransparency = true
        
        gameView.addSubview(skView as UIView)
        
        //        skView.showsFPS = true
        //        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene = GameScene(size: self.view.frame.size)
        scene.scaleMode = .AspectFill
        scene.backgroundColor = UIColor.clearColor()
        skView.presentScene(scene)
        
        return gameView
    }
    
    func setupGameManager() -> UIView {
        managerView = UIView(frame: self.view.frame)
        
        let skView = SKView(frame: view.frame)
        skView.allowsTransparency = true
        
        managerView.addSubview(skView as UIView)
        skView.ignoresSiblingOrder = true
        
        manager = GameManager(size: self.view.frame.size)
        manager.scaleMode = .AspectFill
        manager.backgroundColor = UIColor.clearColor()
        skView.presentScene(manager)
        return managerView
    }
    
    func resetGame() {
        (UIApplication.sharedApplication().delegate as! AppDelegate).gameState = .postGame
        self.scene.removeAllChildren()
        
        self.cameraHandler.session.stopRunning()
        if scene.gameTimer != nil {
            self.scene.gameTimer.invalidate()
        }
        
        
        managerView.removeFromSuperview()
        gameView.removeFromSuperview()
        
        self.collectionView.reloadData()
        setupGameLayer()
        setupGameManager()
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).gameState = .preGame
        self.manager.timer.xScale = 1.0
        self.cameraHandler.session.startRunning()
    }
    
    func startRecording() {
        //start basketball drops and mouth sprite updates
        (UIApplication.sharedApplication().delegate as! AppDelegate).gameState = .inPlay
        self.scene.alreadyStarting = false
        self.scene.addGameTimer()
    }
    
    //MARK: custom UIKitDelegate
    func loadPostGameModal() {
        print("load post game modal")
        self.resetGame()
    }

}
