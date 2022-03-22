//
//  AppDelegate.swift
//  rtc_demo
//
//  Created by apple on 2021/11/29.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    internal var window: UIWindow?
    private let config = Config.default
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ///开启打印日志
//        DebugLogger.shared().enableTTYLogging()
//        DebugLogger.shared().enableFileLogging()
        
        ///创建主控制器，传入socket 和 webrtc
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = self.buildMainViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

    private func buildMainViewController() -> UIViewController {
        
        let mainVc = OCMainViewController.init(nibName: "OCMainViewController", bundle: Bundle.main)
        
//        let webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers, uid: 0)
////        let siganlClient = self.buildSignalingCliend()
//        let mainViewC = MainViewController(webRTCClient: webRTCClient)
        let navVc = UINavigationController(rootViewController: mainVc)
        return navVc
    }
    

}

