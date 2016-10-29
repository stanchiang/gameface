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
    let previewView = UIView()
    let inset:CGFloat = 25
    var videoURL:NSURL!
    var player:AVPlayer!
    var playerLayer:AVPlayerLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clearColor()
        self.blurView()
        
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        restartButton.contentMode = .ScaleAspectFit
        
        restartButton.setImage(resetIcon, forState: .Normal)
        restartButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        restartButton.addTarget(self, action: #selector(restartAction(_:)), forControlEvents: .TouchUpInside)
        restartButton.backgroundColor = UIColor.clearColor()
        addSubview(restartButton)
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.contentMode = .ScaleAspectFit
        shareButton.setImage(shareIcon, forState: .Normal)
        shareButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        shareButton.addTarget(self, action: #selector(shareAction(_:)), forControlEvents: .TouchUpInside)
        shareButton.backgroundColor = UIColor.clearColor()
        addSubview(shareButton)
        
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.backgroundColor = UIColor.clearColor()
        addSubview(previewView)
    }

    func loadVideo(previewURL: NSURL){
        videoURL = previewURL
        player = AVPlayer(URL: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.previewView.frame
        self.previewView.layer.addSublayer(playerLayer)
        player.play()
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(playerItemDidReachEnd(_:)),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: self.player.currentItem)
        
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.player.seekToTime(kCMTimeZero)
        self.player.play()
    }
    
    override func layoutSubviews() {
        restartButton.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor, constant: self.frame.width * -1/5).active = true
        restartButton.widthAnchor.constraintEqualToConstant(self.frame.width * 1/5).active = true
        restartButton.heightAnchor.constraintEqualToAnchor(restartButton.widthAnchor).active = true
        restartButton.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: self.frame.width * -1/20).active = true
        
        shareButton.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: self.frame.width * 1/5).active = true
        shareButton.widthAnchor.constraintEqualToConstant(self.frame.width * 1/5).active = true
        shareButton.heightAnchor.constraintEqualToAnchor(shareButton.widthAnchor).active = true
        shareButton.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: self.frame.width * -1/20).active = true
        
        previewView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        previewView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        previewView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        previewView.bottomAnchor.constraintEqualToAnchor(restartButton.topAnchor, constant: self.frame.width * -1/20).active = true
    }
    
    func restartAction(sender: UIButton) {
        print("restart game")
        delegate?.initNewGame()
    }
    
    func shareAction(sender: UIButton) {
        print("share game")
        
        let activityViewController = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
        (window?.rootViewController as! GameGallery).presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

