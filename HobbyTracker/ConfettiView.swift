//
//  ConfettiView.swift
//  HobbyTracker
//
//  Created by David J Tinley on 12/10/25.
//

import SwiftUI

struct ConfettiView: View {
    var body: some View {
        ZStack {
            // Increased count slightly for a better "shower" effect
            ForEach(0..<60, id: \.self) { _ in
                ConfettiParticle()
            }
        }
        // No .onAppear needed here since particles handle their own animation
    }
}

struct ConfettiParticle: View {
    // 1. Random Position
    @State private var xPos = Double.random(in: -20.0...350.0)
    @State private var yPos = Double.random(in: -600.0...(-100.0)) // Start way above screen
    
    // 2. Random Rotation (3D Tumbling)
    @State private var rotationX = Double.random(in: 0.0...360.0)
    @State private var rotationY = Double.random(in: 0.0...360.0)
    @State private var rotationZ = Double.random(in: 0.0...360.0)
    
    // 3. Random Scale (Depth)
    @State private var scale = Double.random(in: 0.6...1.2)
    
    // 4. The "Loot" Content
    let content = ["💀", "⚔️", "🛡️", "🩸"].randomElement()!
    
    var body: some View {
        Text(content)
            .font(.system(size: 30))
            .scaleEffect(scale) // Apply random size
            // 3D Rotation Effect makes it look like it's tumbling through air
            .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
            .rotationEffect(.degrees(rotationZ))
            .position(x: xPos, y: yPos)
            .onAppear {
                // 5. Staggered Animation
                // Randomize speed AND delay so they don't all fall at once
                let duration = Double.random(in: 2.0...4.0)
                let delay = Double.random(in: 0.0...0.5)
                
                withAnimation(.easeIn(duration: duration).delay(delay)) {
                    yPos += 1200 // Fall down past bottom of screen
                    
                    // Spin violently as they fall
                    rotationX += Double.random(in: 360...720)
                    rotationY += Double.random(in: 360...720)
                    rotationZ += Double.random(in: 180...360)
                }
            }
    }
}

#Preview {
    ConfettiView()
        .background(Color.black.opacity(0.8)) // Dark background to see the loot pop!
}
