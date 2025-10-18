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
    @StateObject var interstitialAdsManager = InterstitialAdsManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        print("🎬 CoderQuestApp initialized")
    }
    
    var body: some Scene {
        WindowGroup {
            // Temporarily bypass splash screen for testing
            MainMenuView()
                .environmentObject(interstitialAdsManager)
                .onAppear {
                    print("✅ MainMenuView loaded successfully!")
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
