//
// ---------------------------- //
// Original Project: Pendulum
// Created on 2024-10-02 by Tim Mitra
// Mastodon: @timmitra@mastodon.social
// Twitter/X: timmitra@twitter.com
// Web site: https://www.it-guy.com
// ---------------------------- //
// Copyright © 2024 iT Guy Technologies. All rights reserved.


import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @State var ballEntity = Entity()

    var body: some View {
        RealityView { content in
            
            let attachmentEntity = ModelEntity(mesh: .generateBox(width: 0.2, height: 0.025, depth: 0.2), materials: [SimpleMaterial(color: .green, isMetallic: false)])
            attachmentEntity.position.y = 0.45
            content.add(attachmentEntity)
            
            let stringEntity = ModelEntity(mesh: .generateCylinder(height: 1.5, radius: 0.005), materials: [SimpleMaterial(color: .gray, isMetallic: false)])
            attachmentEntity.addChild(stringEntity)
            
            let ballEntity = ModelEntity(
                mesh: .generateSphere(radius: 0.05),
                materials: [SimpleMaterial(color: .white, isMetallic: true)])
            ballEntity.position.y = -0.75
            ballEntity.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.05)]))
            stringEntity.addChild(ballEntity)
           }
            
        }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
