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
    let pendulumSettings = PendulumSettings()

    
    var body: some View {
        RealityView { content in
            
            /* Occluded floor */
            let floor = ModelEntity(mesh: .generatePlane(width: 100, depth: 100), materials: [OcclusionMaterial()])
            floor.generateCollisionShapes(recursive: false)
            floor.components[PhysicsBodyComponent.self] = .init(
              massProperties: .default,
              mode: .static
            )
            floor.position.y = -0.5
            content.add(floor)
            
            let pendulumParent = ModelEntity()
            content.add(pendulumParent)
            
            let attachmentEntity = makeAttachmentEntity()
            attachmentEntity.position.y = 0.45
            pendulumParent.addChild(attachmentEntity)
            
            let stringEntity = makeStringEntity()
            attachmentEntity.addChild(stringEntity)
            
            let ballEntity = makeBallEntity()
            //ballEntity.position.y = -0.65
            pendulumParent.addChild(ballEntity)
           }
        }
    
    func makeAttachmentEntity() -> Entity {
        let attachmentEntity = ModelEntity(mesh: .generateBox(size: pendulumSettings.attachmentSize), materials: [SimpleMaterial(color: pendulumSettings.attachmentColor, isMetallic: false)])
        
        let attachmentShape = ShapeResource.generateBox(
            size: pendulumSettings.attachmentSize * pendulumSettings.ballRadius
        )

        var attachmentBody = PhysicsBodyComponent(
            shapes: [attachmentShape], mass: 1,
            material: .generate(staticFriction: 0, dynamicFriction: 0, restitution: 1),
            mode: .static
        )
        attachmentBody.linearDamping = 0
        let attachmentCollision = CollisionComponent(shapes: [attachmentShape])

        attachmentEntity.components.set([attachmentBody, attachmentCollision])
        
        return attachmentEntity
    }
    
    func makeBallEntity() -> Entity {
        
        let ballEntity = ModelEntity(
            mesh: .generateSphere(radius: pendulumSettings.ballRadius),
            materials: [SimpleMaterial(color: .white, isMetallic: true)])
        ballEntity.components.set(CollisionComponent(shapes: [.generateSphere(radius: pendulumSettings.ballRadius)]))
        
        let ballCollisionShape = ShapeResource.generateSphere(
            radius: pendulumSettings.ballRadius)

        var ballBody = PhysicsBodyComponent(
            shapes: [ballCollisionShape],
            mass: pendulumSettings.ballMass,
            material: .generate(staticFriction: 0, dynamicFriction: 0, restitution: 1),
            mode: .dynamic
        )
        ballBody.linearDamping = 0
        
        let ballShape = ballCollisionShape
        let ballCollision = CollisionComponent(shapes: [ballShape])
        
        ballEntity.components.set([ballBody, ballCollision])
        
        return ballEntity
    }
    
    func makeStringEntity() -> Entity {
        let stringEntity = ModelEntity(mesh: .generateCylinder(height: pendulumSettings.stringLength, radius: pendulumSettings.stringRadius), materials: [SimpleMaterial(color: pendulumSettings.stringColor, isMetallic: false)])
        return stringEntity
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
