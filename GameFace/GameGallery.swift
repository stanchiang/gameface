//
//  GameGallery.swift
//  GameFace
//
//  Created by Stanley Chiang on 10/14/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SpriteKit

class GameGallery: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UIKitDelegate, PostGameViewDelegate {
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
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
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
    
    var mouth:[CGPoint]!
    
    var debugView:DebugView!
    let debugMode = true
    
    var gamePlayArray = [UIImage]()
    var screenShot = UIImage()
    
    var isWritingToVideo = false
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var postGameModal:PostGameView!
    
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
        appDelegate.currentCell = 1
        
        if postGameModal != nil {
            postGameModal.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor).active = true
            postGameModal.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor).active = true
            postGameModal.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
            postGameModal.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor).active = true

        }
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
            if debugMode {
                cell.contentView.addSubview(debugView)
            } else {
                cell.note.alpha = 1
            }
        }
        
        if indexPath.row == 1 {
            cell.note.alpha = 0
            cell.contentView.addSubview(setupGameLayer())
            cell.contentView.addSubview(setupGameManager())
            
            scene.sceneDelegate = manager
            scene.gameVarDelegate = debugView
            manager.managerDelegate = scene
            manager.uikitDelegate = self
            
            appDelegate.gameState = .preGame
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        resetGame()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if collectionView.visibleCells().count == 1 {
            for cell in collectionView.visibleCells() {
                let cell = cell as! CustomCollectionViewCell
//                if collectionView.indexPathForCell(cell)!.row == 0 {
//                    cameraHandler.session.stopRunning()
//                } else {
//                    cameraHandler.session.startRunning()
//                }
                appDelegate.currentCell = collectionView.indexPathForCell(cell)!.row
            }
        }
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
        
        
        if let score:Double = appDelegate.userDefaults.doubleForKey("highScore") {
            print("load high score \(score)")
            appDelegate.highScore = score
        } else {
            print("init high score")
            appDelegate.userDefaults.setDouble(0, forKey: "highScore")
        }
        
        return managerView
    }
    
    func resetGame() {
        destroyGame()
        initNewGame()
    }
    
    func destroyGame(){
        self.scene.removeAllChildren()
        
        self.cameraHandler.session.stopRunning()
        if scene.gameTimer != nil {
            self.scene.gameTimer.invalidate()
        }
        
        managerView.removeFromSuperview()
        gameView.removeFromSuperview()

    }
    
    func initNewGame(){
        appDelegate.currentScore = 0
        appDelegate.mouth = []
        gamePlayArray = []
        
        if postGameModal != nil {
            postGameModal.removeFromSuperview()
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        }
        postGameModal = nil
        isWritingToVideo = false
        
        self.collectionView.reloadData()
        setupGameLayer()
        setupGameManager()
        
        appDelegate.gameState = .preGame
        self.manager.timer.xScale = 1.0
        self.cameraHandler.session.startRunning()
    }
    
    func startPlaying() {
        //start basketball drops and mouth sprite updates
        appDelegate.gameState = .inPlay
        self.scene.addGameTimer()
    }
    
    //MARK: custom UIKitDelegate
    func loadPostGame() {
        
        //update highscore if needed
        if manager.hasHighScore {
            appDelegate.userDefaults.setDouble(appDelegate.currentScore, forKey: "highScore")
            print("updated high score \(appDelegate.currentScore)")
        }
        
        //destroy current game
        destroyGame()
        
        //load post game modal
        print("load post game")
        postGameModal = PostGameView()
        postGameModal.delegate = self
        view.addSubview(postGameModal)
        
        //create video
        if !isWritingToVideo {
            isWritingToVideo = true
            gamePlayToVideo(gamePlayArray)
        }
    }
    
    func takeScreenShot(){
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view?.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        var screenShot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        gamePlayArray.append(screenShot!)
        screenShot = nil
        print("screenshot # \(gamePlayArray.count)")
    }
    
    func gamePlayToVideo(inputArray:[UIImage]){
        let settings = RenderSettings()
        let imageAnimator = ImageAnimator(renderSettings: settings, imageArray: inputArray)
        imageAnimator.render { [unowned self] videoURL in
            if self.postGameModal != nil {
                self.postGameModal.loadVideo(videoURL)                
            }
        }
    }
}
