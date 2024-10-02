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
//                    let model = ModelEntity(
//                                 mesh: .generateSphere(radius: 0.05),
//                                 materials: [SimpleMaterial(color: .white, isMetallic: true)])
//                    content.add(model)
                //}
            
            let ballEntity = ModelEntity(
                mesh: .generateSphere(radius: 0.05),
                materials: [SimpleMaterial(color: .white, isMetallic: true)])
//            ballEntity.position.x = 0.0
            ballEntity.position.y = -0.425
//            ballEntity.position.y = -1.5
            ballEntity.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.05)]))
            content.add(ballEntity)
            
            let attachmentEntity = ModelEntity(mesh: .generateBox(width: 0.2, height: 0.025, depth: 0.2), materials: [SimpleMaterial(color: .green, isMetallic: false)])
            attachmentEntity.position.y = 0.45
            content.add(attachmentEntity)
            
                let stringEntity = ModelEntity(mesh: .generateCylinder(height: 1.5, radius: 0.005), materials: [SimpleMaterial(color: .gray, isMetallic: false)])
            //    stringEntity.position = [0.0, 1.0, -1.5]
                content.add(stringEntity)
           }
            
        }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
