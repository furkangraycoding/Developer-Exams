//
//  InterstitialAdsManager.swift
//  FlashCard
//
//  Created by furkan gurcay on 12.12.2024.
//

import Foundation
import SwiftUI
import SwiftData
import GoogleMobileAds

class InterstitialAdsManager: NSObject, GADFullScreenContentDelegate, ObservableObject {
    
    // Properties
   @Published var interstitialAdLoaded:Bool = false
    var interstitialAd:GADInterstitialAd?
    static var withoutAdCounter : Int = 0
    
    override init() {
        super.init()
    }
    
    // Load InterstitialAd
    func loadInterstitialAd() {
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-8707747310682332/9743427999", request: GADRequest()) { [weak self] add, error in
            guard let self = self else {return}
            if let error = error{
                print("🔴: \(error.localizedDescription)")
                self.interstitialAdLoaded = false
                return
            }
            print("🟢: Loading succeeded")
            self.interstitialAdLoaded = true
            self.interstitialAd = add
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }
    
    // Display InterstitialAd
    func displayInterstitialAd(){
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let root = windowScene?.windows.first?.rootViewController else {
            return
        }
        InterstitialAdsManager.withoutAdCounter += 1
        if InterstitialAdsManager.withoutAdCounter >= 2 {
            if let add = interstitialAd {
            print("🔵: interstitialAd withoutAdCounter :" + String((InterstitialAdsManager.withoutAdCounter)))
            
            add.present(fromRootViewController: root)
            self.interstitialAdLoaded = true
            InterstitialAdsManager.withoutAdCounter = 0
        }
        }
            else{
                print("🔵: Ad wasn't ready")
                print("🔵: withoutAdCounter :" + String((InterstitialAdsManager.withoutAdCounter)))
                if InterstitialAdsManager.withoutAdCounter == 2 {
                    self.interstitialAdLoaded = false
                    self.loadInterstitialAd()
                }
            }
    }
    
    // Failure notification
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("🟡: Failed to display interstitial ad")
        self.loadInterstitialAd()
    }
    
    // Indicate notification
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("🤩: Displayed an interstitial ad")
        self.interstitialAdLoaded = false
    }
    
    // Close notification
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("😔: Interstitial ad closed")
    }
}

