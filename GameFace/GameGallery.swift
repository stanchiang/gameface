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

class GameGallery: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIKitDelegate, PostGameViewDelegate {
    lazy var collectionView:UICollectionView = {
        var cv = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.bounces = true
        cv.alwaysBounceHorizontal = true
        cv.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        cv.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        cv.backgroundColor = UIColor.clear
        cv.isPagingEnabled = true
        return cv
    }()
    
    lazy var flowLayout:UICollectionViewFlowLayout = {
        var flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
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
    var transformView:BCMeshTransformView!
    
    var gameView:UIView!
    var managerView:UIView!
    var powerupView:UIView!
    
    var scene:GameScene!
    var manager:GameManager!

    var mouth:[CGPoint]!
    
    var debugView:DebugView!
    let debugMode = false
    
    var gamePlayArray = [UIImage]()
    var screenShot = UIImage()
    
    var isWritingToVideo = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var postGameModal:PostGameView!
    
    var testWarp:BCMutableMeshTransform!

    var spacer1:UIView = UIView()
    var powerUp1:UIButton = UIButton()
    
    var spacer2:UIView = UIView()
    var powerUp2:UIButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        cameraHandler.openSession()
        setupCameraImage()
        
        debugView = DebugView(frame: self.view.frame)
        
        self.items.addObjects(from: ["Card #1"])
        self.items.addObjects(from: ["Card #2"])
        self.view.addSubview(self.collectionView)
    }

    func setupCameraImage(){
        transformView = BCMeshTransformView(frame: self.view.bounds)
        transformView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        
        self.view.addSubview(transformView)
        
        cameraImage = UIImageView()
        cameraImage.frame = self.view.frame
        transformView.contentView.addSubview(cameraImage)
        
        // we don't want any shading on this one
        transformView.diffuseLightFactor = 0.0
        
        cameraImage.transform = self.cameraImage.transform.scaledBy(x: -1, y: 1)

//        let points = [CGPoint(x: 188.720858895706, y: 449.717791411043)]
        let points = [CGPoint(x: 135, y: 314), CGPoint(x: 302, y: 314)]
//        testWarp = bulgeWarp(at: points, withRadius: 120.0, boundSize: self.transformView.bounds.size)
//        updateWarp(points: points)
    }
    
    func updateWarp(points:[CGPoint]){
        self.transformView.meshTransform = bulgeWarp(at: points, withRadius: 120.0, boundSize: self.transformView.bounds.size)        
    }
    
    func bulgeWarp(at points:[CGPoint], withRadius radius:CGFloat, boundSize size:CGSize) -> BCMutableMeshTransform {
        let Bulginess:CGFloat = 0.4
        let transform = BCMutableMeshTransform.identityMeshTransform(withNumberOfRows: 36, numberOfColumns: 36)
        
        let rMax:CGFloat = radius/size.width
        let yScale:CGFloat = size.height/size.width
        
        for point in points {
            let x:CGFloat = point.x/size.width;
            let y:CGFloat = point.y/size.height
            
            let vertexCount = transform?.vertexCount
            for i in 0..<vertexCount! {
                var v:BCMeshVertex = transform!.vertex(at: i)
                let dx:CGFloat = v.to.x - x
                let dy:CGFloat = (v.to.y - y) * yScale
                
                let r:CGFloat = sqrt(dx*dx + dy*dy)
                
                if r > rMax {
                    continue
                }
                
                let t:CGFloat = r/rMax
                let scale:CGFloat = Bulginess*(cos(t * CGFloat(M_PI)) + 1.0)
                
                v.to.x += dx * scale
                v.to.y += dy * scale / yScale
                v.to.z = scale * 0.2
                
                transform?.replaceVertex(at: i, with: v)
            }
        }
        return transform!
    }
    
    override func viewWillLayoutSubviews() {
        if postGameModal != nil {
            postGameModal.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            postGameModal.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            postGameModal.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            postGameModal.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        }
        
        if powerupView != nil {
            powerupView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            powerupView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            powerupView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
            powerupView.heightAnchor.constraint(equalToConstant: self.view.frame.size.width / 2).isActive = true
        }
        
        if let superview = spacer1.superview {
            spacer1.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
            spacer1.trailingAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
            spacer1.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
            spacer1.heightAnchor.constraint(equalTo: superview.heightAnchor).isActive = true
        }
        
        if let superview = spacer2.superview {
            spacer2.leadingAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
            spacer2.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            spacer2.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
            spacer2.heightAnchor.constraint(equalTo: superview.heightAnchor).isActive = true
        }
        
        if let superview = powerUp1.superview {
            powerUp1.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
            powerUp1.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
            powerUp1.widthAnchor.constraint(equalTo: superview.widthAnchor, constant: -self.view.frame.width / 5).isActive = true
            powerUp1.heightAnchor.constraint(equalTo: powerUp1.widthAnchor).isActive = true
        }
        
        if let superview = powerUp2.superview {
            powerUp2.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
            powerUp2.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
            powerUp2.widthAnchor.constraint(equalTo: superview.widthAnchor, constant: -self.view.frame.width / 5).isActive = true
            powerUp2.heightAnchor.constraint(equalTo: powerUp2.widthAnchor).isActive = true
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: UICollectionViewScrollPosition(), animated: false)
        appDelegate.currentCell = 1
        
        powerUp1.layer.borderColor = UIColor.black.cgColor
        powerUp1.layer.borderWidth = 3
        powerUp1.layer.cornerRadius = powerUp1.frame.width / 2
        
        powerUp2.layer.borderColor = UIColor.black.cgColor
        powerUp2.layer.borderWidth = 3
        powerUp2.layer.cornerRadius = powerUp2.frame.width / 2
    }
    
    //MARK: Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        
        let width:CGFloat = self.view.bounds.size.width
        let height:CGFloat = self.view.bounds.size.height
        
        return CGSize(width: width, height: height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.flowLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        
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
            cell.contentView.addSubview(setupPowerupView())
            
            scene.sceneDelegate = manager
            scene.gameVarDelegate = debugView
            manager.managerDelegate = scene
            manager.uikitDelegate = self
            
            appDelegate.gameState = .preGame
        }
        
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if appDelegate.gameState != .inPlay { resetGame() }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if collectionView.visibleCells.count == 1 {
            for cell in collectionView.visibleCells {
                let cell = cell as! CustomCollectionViewCell
//                if collectionView.indexPathForCell(cell)!.row == 0 {
//                    cameraHandler.session.stopRunning()
//                } else {
//                    cameraHandler.session.startRunning()
//                }
                appDelegate.currentCell = collectionView.indexPath(for: cell)!.row
            }
        }
    }
    
    //MARK: Basketball SpriteKit methods
    func setupGameLayer() -> UIView {
        gameView = UIView(frame: self.view.frame)
        gameView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        gameView.transform = gameView.transform.scaledBy(x: 1, y: -1)

        let skView = SKView(frame: view.frame)
        skView.allowsTransparency = true
        
        gameView.addSubview(skView as UIView)
        
        //        skView.showsFPS = true
        //        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene = GameScene(size: self.view.frame.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.clear
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
        manager.scaleMode = .aspectFill
        manager.backgroundColor = UIColor.clear
        skView.presentScene(manager)
        
        
        if let score:Double = appDelegate.userDefaults.double(forKey: "highScore") {
//            print("load high score \(score)")
            appDelegate.highScore = score
        } else {
//            print("init high score")
            appDelegate.userDefaults.set(0, forKey: "highScore")
        }
        
        return managerView
    }
    
    func setupPowerupView() -> UIView {
        powerupView = UIView()
        powerupView.translatesAutoresizingMaskIntoConstraints = false
        
        let inset:CGFloat = 30
        
        spacer1.translatesAutoresizingMaskIntoConstraints = false
        powerupView.addSubview(spacer1)
        
        let shades = UIImage(named: "shades")
        powerUp1.translatesAutoresizingMaskIntoConstraints = false
        powerUp1.setImage(shades, for: UIControlState.normal)
        powerUp1.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        powerUp1.addTarget(self, action: #selector(powerup1TouchDown(sender:)), for: UIControlEvents.touchDown)
        powerUp1.addTarget(self, action: #selector(powerup1TouchUpInside(sender:)), for: UIControlEvents.touchUpInside)
        spacer1.addSubview(powerUp1)

        spacer2.translatesAutoresizingMaskIntoConstraints = false
        powerupView.addSubview(spacer2)
        
        let mustache = UIImage(named: "mustache")
        powerUp2.translatesAutoresizingMaskIntoConstraints = false
        powerUp2.setImage(mustache, for: UIControlState.normal)
        powerUp2.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        powerUp2.addTarget(self, action: #selector(powerup2TouchDown(sender:)), for: UIControlEvents.touchDown)
        powerUp2.addTarget(self, action: #selector(powerup2TouchUpInside(sender:)), for: UIControlEvents.touchUpInside)
        spacer2.addSubview(powerUp2)

        return powerupView
    }
    
    func powerup1TouchDown(sender: UIButton){
        print("in button action")
        manager.startPowerUp(.slomo)
        powerUp1.alpha = 0.5
    }
    
    func powerup1TouchUpInside(sender: UIButton){
        manager.endPowerUp(.slomo)
        powerUp1.alpha = 1
    }
    
    func powerup2TouchDown(sender: UIButton){
        manager.startPowerUp(.catchall)
        powerUp2.alpha = 0.5
    }
    
    func powerup2TouchUpInside(sender: UIButton){
        manager.endPowerUp(.catchall)
        powerUp2.alpha = 1
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
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
        postGameModal = nil
        isWritingToVideo = false
        
        collectionView.reloadData()
        collectionView.isScrollEnabled = true
        _ = setupGameLayer()
        _ = setupGameManager()
        
        appDelegate.gameState = .preGame
        manager.timer.xScale = 1.0
        cameraHandler.session.startRunning()
    }
    
    func startPlaying() {
        //start basketball drops and mouth sprite updates
        appDelegate.gameState = .inPlay
        self.scene.addGameTimer()
    }
    
    //MARK: custom UIKitDelegate
    func loadPostGame() {
        
        //update highscore if needed
        if manager.hasNewHighScore {
            appDelegate.userDefaults.set(appDelegate.currentScore, forKey: "highScore")
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
        self.view?.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        var screenShot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        gamePlayArray.append(screenShot!)
        screenShot = nil
//        print("screenshot # \(gamePlayArray.count)")
    }
    
    func gamePlayToVideo(_ inputArray:[UIImage]){
        let settings = RenderSettings()
        let imageAnimator = ImageAnimator(renderSettings: settings, imageArray: inputArray)
        imageAnimator.render { [unowned self] videoURL in
            if self.postGameModal != nil {
                self.postGameModal.loadVideo(videoURL)                
            }
        }
    }
}
