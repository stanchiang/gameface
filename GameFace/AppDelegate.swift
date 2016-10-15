//
//  AppDelegate.swift
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 15.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mouth = [CGPoint]()

    var currentCell:Int!
    var gameState = GameState.preGame
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = GameGallery()
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
//        if gameState == .inPlay {
//            (window?.rootViewController as! GameGallery).manager.togglePause()
//        }
        
        (window?.rootViewController as! GameGallery).resetGame()
    }
}
