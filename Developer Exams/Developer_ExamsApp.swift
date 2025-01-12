//
//  Developer_ExamsApp.swift
//  Developer Exams
//
//  Created by furkan gurcay on 12.01.2025.
//

import SwiftUI
import GoogleMobileAds

@main
struct Developer_ExamsApp: App {
    @State private var isActive = false
    @State private var username: String = "" // Kullanıcının girdiği takma ad
    @StateObject var interstitialAdsManager = InterstitialAdsManager()

    var body: some Scene {
        WindowGroup {
            if isActive {
                ContentView(username: username)
            } else {
                VStack {
                    Text("Developer Exams")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    
                    TextField("Nickname...", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        withAnimation {
                            isActive = true
                        }
                    }) {
                        Text("Go")
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue)
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
