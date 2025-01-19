//
//  GlobalViewModel.swift
//  Developer Exams
//
//  Created by furkan gurcay on 14.01.2025.
//

import Foundation


class GlobalViewModel: ObservableObject {
    @Published var chosenMenu: String = ""
    @Published var isActive: String = "SplashEkranı"
    @Published var username: String = ""
    
    static let shared = GlobalViewModel()
}
