//
//  PostGameView.swift
//  GameFace
//
//  Created by Stanley Chiang on 10/24/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol PostGameViewDelegate:class {
    func initNewGame()
}

class PostGameView: UIView {

    weak var delegate:PostGameViewDelegate?
    
    let restartButton = UIButton()
    let resetIcon = UIImage(named: "redo")
    let shareButton = UIButton()
    let shareIcon = UIImage(named: "share")
    let continueButton = UIButton()
    let continueIcon = UIImage(named: "play")
    var continueTimer: KDCircularProgress!
    
    let previewView = UIView()
    let inset:CGFloat = 25
    var videoURL:URL!
    var player:AVPlayer!
    var playerLayer:AVPlayerLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.blurView()
        
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        restartButton.contentMode = .scaleAspectFit
        
        restartButton.setImage(resetIcon, for: UIControlState.normal)
        restartButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        restartButton.addTarget(self, action: #selector(restartAction(_:)), for: .touchUpInside)
        restartButton.backgroundColor = UIColor.clear
        addSubview(restartButton)
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.contentMode = .scaleAspectFit
        shareButton.setImage(shareIcon, for: UIControlState.normal)
        shareButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        shareButton.addTarget(self, action: #selector(shareAction(_:)), for: .touchUpInside)
        shareButton.backgroundColor = UIColor.clear
        addSubview(shareButton)
        
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.backgroundColor = UIColor.clear
        addSubview(previewView)
        
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.contentMode = .scaleAspectFit
        continueButton.setImage(continueIcon, for: UIControlState.normal)
        continueButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        continueButton.addTarget(self, action: #selector(restartAction(_:)), for: .touchUpInside)
        continueButton.backgroundColor = UIColor.clear
        continueButton.layer.borderColor = UIColor.red.cgColor
        continueButton.layer.borderWidth = 5.0
        addSubview(continueButton)
        
        continueTimer = KDCircularProgress()
        continueTimer.translatesAutoresizingMaskIntoConstraints = false
        continueTimer.startAngle = -90
        continueTimer.progressThickness = 0.3
        continueTimer.trackThickness = 0.3
        continueTimer.trackColor = UIColor.white
        continueTimer.clockwise = true
        continueTimer.roundedCorners = false
        continueTimer.glowMode = .noGlow
        addSubview(continueTimer)
        
        
    }
    

    func loadVideo(_ previewURL: URL){
        videoURL = previewURL
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.previewView.frame
        self.previewView.layer.addSublayer(playerLayer)
        player.play()
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(playerItemDidReachEnd(_:)),
                                                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                         object: self.player.currentItem)
        
        startContinueTimer()
    }
    
    func playerItemDidReachEnd(_ notification: Notification) {
        self.player.seek(to: kCMTimeZero)
        self.player.play()
    }
    
    override func layoutSubviews() {
        restartButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: self.frame.width * -1/5).isActive = true
        restartButton.widthAnchor.constraint(equalToConstant: self.frame.width * 1/5).isActive = true
        restartButton.heightAnchor.constraint(equalTo: restartButton.widthAnchor).isActive = true
        restartButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: self.frame.width * -1/20).isActive = true
        
        shareButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.frame.width * 1/5).isActive = true
        shareButton.widthAnchor.constraint(equalToConstant: self.frame.width * 1/5).isActive = true
        shareButton.heightAnchor.constraint(equalTo: shareButton.widthAnchor).isActive = true
        shareButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: self.frame.width * -1/20).isActive = true
        
        previewView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        previewView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: restartButton.topAnchor, constant: self.frame.width * -1/20).isActive = true
        
        continueButton.centerYAnchor.constraint(equalTo: previewView.centerYAnchor).isActive = true
        continueButton.leadingAnchor.constraint(equalTo: previewView.trailingAnchor).isActive = true
        continueButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        continueButton.heightAnchor.constraint(equalTo: continueButton.widthAnchor).isActive = true
        
        continueTimer.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor).isActive = true
        continueTimer.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor).isActive = true
        continueTimer.widthAnchor.constraint(equalTo: continueButton.widthAnchor).isActive = true
        continueTimer.heightAnchor.constraint(equalTo: continueButton.heightAnchor).isActive = true
    }
    
    func restartAction(_ sender: UIButton) {
        print("restart game")
        delegate?.initNewGame()
    }
    
    func shareAction(_ sender: UIButton) {
        print("share game")
        var activityItems = [AnyObject]()
        if videoURL != nil {
            activityItems.append(videoURL as AnyObject)
        }
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        (window?.rootViewController as! GameGallery).present(activityViewController, animated: true, completion: nil)
    }
    
    func startContinueTimer() {
        continueTimer.animate(fromAngle: 0, toAngle: 360, duration: 3) { [unowned self] completed in
            if completed {
                print("animation stopped, completed")
                self.continueButton.alpha = 0
            } else {
                print("animation stopped, was interrupted")
            }
        }

//        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
    }
    
//    func timerAction(){
//        continueButton.alpha = 0
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
