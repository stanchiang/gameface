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
    var currentScore:Double = 0
    var highScore:Double = 0
    
    var userDefaults = NSUserDefaults.standardUserDefaults()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = GameGallery()
        
//        let numberOfTableViewRows: NSInteger = 3
//        let numberOfCollectionViewCells: NSInteger = 3
//        
//        var source = Array<AnyObject>()
//        for _ in 0..<numberOfTableViewRows {
//            var colorArray = Array<UIColor>()
//            for _ in 0..<numberOfCollectionViewCells {
//                let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
//                colorArray.append(color)
//            }
//            source.append(colorArray as AnyObject)
//        }
//
//        // the source format is Array<Array<AnyObject>>
//        let viewController = CollectionTableViewController(source: source)
//        window?.rootViewController = viewController
        
        window?.makeKeyAndVisible()
        Tracker.sharedInstance.loginRequest()
        return true

    }
    
    func applicationWillResignActive(application: UIApplication) {
        (window?.rootViewController as! GameGallery).resetGame()
    }
    
//    func loginRequest() {
//        let loginRequest:LoginWithCustomIDRequest = LoginWithCustomIDRequest()
//        loginRequest.CustomId = UIDevice.currentDevice().identifierForVendor?.UUIDString
//        loginRequest.CreateAccount = true
//        
//        PlayFabClientAPI.GetInstance().LoginWithCustomID(loginRequest,
//            success: { (result:LoginResult!, userData:NSObject!) in
//                print("success: \n \(result.PlayFabId) \n \(result.LastLoginTime) \n \(userData)")
//            }, failure: { (error:PlayFabError!, userData:NSObject!) in
//                print("error: \n \(error.errorCode) \(error.errorMessage) \n \(error.errorDetails) \n \(userData)")
//            }, withUserData: nil
//        )
//    }
}
