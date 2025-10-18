//
//  GlobalViewModel.swift
//  Developer Exams
//
//  Created by furkan gurcay on 14.01.2025.
//

import Foundation
import SwiftUICore


class GlobalViewModel: ObservableObject {
    @Published var chosenMenu: String = ""
    @Published var chosenMenuColor: Color = Color.black
    @Published var isActive: String = "SplashEkranı"
    @Published var username: String = ""
    @Published var isMenuVisible: Bool = true
    @Published var shapesWithPositions: [(shape: AnyView, position: CGPoint)] = []
    @Published var selectedDifficulty: DifficultyLevel = .easy
    
    static let shared = GlobalViewModel()
}
