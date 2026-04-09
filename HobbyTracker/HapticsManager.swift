//
//  HapticsManager.swift
//  HobbyTracker
//
//  Created by David J Tinley on 12/10/25.
//

import UIKit

class Haptics {
    static let shared = Haptics()
    
    private init() {}

    // For standard clicks and thuds
    func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    // For "Success", "Error", or "Warning" sequences
    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
