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
    var noseBridge:CGPoint!
    var noseTip:CGPoint!
    var mustache:CGPoint!
    
    var currentCell:Int!
    var gameState = GameState.preGame
    var currentScore:Double = 0
    var highScore:Double = 0
    var activePowerups = [PowerUp]()
    
    var userDefaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.rootViewController = GameGallery()
        window?.makeKeyAndVisible()
        window?.frame = UIScreen.main.bounds
        Tracker.sharedInstance.loginRequest()
        return true

    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        (window?.rootViewController as! GameGallery).resetGame()
    }

}
