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
    let shareButton = UIButton()
    let previewView = UIView()
    
    var videoURL:NSURL!
    var player:AVPlayer!
    var playerLayer:AVPlayerLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.orangeColor()
        
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        restartButton.setTitle("Play Again", forState: .Normal)
        restartButton.addTarget(self, action: #selector(restartAction(_:)), forControlEvents: .TouchUpInside)
        restartButton.backgroundColor = UIColor.blueColor()
        restartButton.layer.borderColor = UIColor.redColor().CGColor
        restartButton.layer.borderWidth = 1.0
        addSubview(restartButton)
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setTitle("Share", forState: .Normal)
        shareButton.addTarget(self, action: #selector(shareAction(_:)), forControlEvents: .TouchUpInside)
        shareButton.backgroundColor = UIColor.greenColor()
        shareButton.layer.borderColor = UIColor.blackColor().CGColor
        shareButton.layer.borderWidth = 1.0
        addSubview(shareButton)
        
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.backgroundColor = UIColor.lightGrayColor()
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
        restartButton.leadingAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        restartButton.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        restartButton.heightAnchor.constraintEqualToConstant(self.frame.height * 0.2).active = true
        restartButton.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        
        shareButton.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        shareButton.trailingAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        shareButton.heightAnchor.constraintEqualToConstant(self.frame.height * 0.2).active = true
        shareButton.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        
        previewView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        previewView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        previewView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        previewView.bottomAnchor.constraintEqualToAnchor(restartButton.topAnchor).active = true
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
