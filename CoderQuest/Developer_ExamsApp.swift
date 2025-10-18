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
            ZStack {
                if !showSplash {
                    MainMenuView()
                        .environmentObject(interstitialAdsManager)
                        .transition(.opacity)
                }
                
                if showSplash {
                    ModernSplashView(showSplash: $showSplash)
                        .transition(.opacity)
                        .zIndex(1)
                }
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
