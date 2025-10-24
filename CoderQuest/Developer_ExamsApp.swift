//
//  Developer_ExamsApp.swift
//  Developer Exams
//
//  Created by furkan gurcay on 12.01.2025.
//

import SwiftUI
import GoogleMobileAds

@main
struct CoderQuestApp: App {
    @State private var isActive = "Login"
    @State private var username: String = ""
    @StateObject var interstitialAdsManager = InterstitialAdsManager()
    @StateObject private var globalViewModel = GlobalViewModel()
    @State private var chosenMenu : String = ""
    
    var body: some Scene {
        WindowGroup {
            if globalViewModel.isActive == "AnaEkran" {
                if globalViewModel.isMenuVisible {
                    MenuView(isMenuVisible: $globalViewModel.isMenuVisible).environmentObject(globalViewModel)
                } else {
                    if globalViewModel.chosenMenu != "" {
                        EnhancedQuizView(
                            username: username,
                            chosenMenu: globalViewModel.chosenMenu
                        ).environmentObject(globalViewModel)
                    }
                }
            }
            else if (globalViewModel.isActive == "Login") {
                UsernameInputView(isActive: $isActive, username : $username).environmentObject(globalViewModel)
                    .onAppear {
                        // Check if username exists and skip login screen
                        if let savedUsername = UserDefaults.standard.string(forKey: "username"), !savedUsername.isEmpty {
                            username = savedUsername
                            globalViewModel.username = savedUsername
                            globalViewModel.isActive = "AnaEkran"
                        }
                    }
            }
        }
    }
}

class AppDelegate:NSObject,UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GADMobileAds.sharedInstance().start()
        return true
    }
}
