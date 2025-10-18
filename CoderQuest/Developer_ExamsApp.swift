//
//  Developer_ExamsApp.swift
//  CoderQuest
//
//  Created by furkan gurcay on 12.01.2025.
//

import SwiftUI
import GoogleMobileAds

@main
struct CoderQuestApp: App {
    @State private var showSplash = true
    @StateObject var interstitialAdsManager = InterstitialAdsManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                ModernSplashView(isActive: $showSplash)
            } else {
                MainMenuView()
                    .environmentObject(interstitialAdsManager)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GADMobileAds.sharedInstance().start()
        return true
    }
}
