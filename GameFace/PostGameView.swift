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
    var videoURL:URL!
    var player:AVPlayer!
    var playerLayer:AVPlayerLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clear
        self.blurView()
        
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        restartButton.contentMode = .scaleAspectFit
        
        restartButton.setImage(resetIcon, for: UIControlState())
        restartButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        restartButton.addTarget(self, action: #selector(restartAction(_:)), for: .touchUpInside)
        restartButton.backgroundColor = UIColor.clear
        addSubview(restartButton)
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.contentMode = .scaleAspectFit
        shareButton.setImage(shareIcon, for: UIControlState())
        shareButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        shareButton.addTarget(self, action: #selector(shareAction(_:)), for: .touchUpInside)
        shareButton.backgroundColor = UIColor.clear
        addSubview(shareButton)
        
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.backgroundColor = UIColor.clear
        addSubview(previewView)
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
        previewView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        previewView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: restartButton.topAnchor, constant: self.frame.width * -1/20).isActive = true
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

