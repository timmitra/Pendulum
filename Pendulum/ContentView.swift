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
    
    @State var ballEntity: Entity? = nil  // Store a reference to the ball entity
    let pendulumSettings = PendulumSettings()
    @State var pushButtonDisabled = false
    @State var pendulums: [Entity] = []

    @MainActor
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
            attachmentEntity.position.y = 0.2
            pendulumParent.addChild(attachmentEntity)
            
            let ballEntity = makeBallEntity()
            ballEntity.position.y = -0.4
            pendulumParent.addChild(ballEntity)
            
            let stringEntity = makeStringEntity()
            stringEntity.position.y = 0.3
            ballEntity.addChild(stringEntity)
            
            // Store reference to the ball entity in @State
            DispatchQueue.main.async {
                self.ballEntity = ballEntity
            }

            // Add physics simulation component to parent simulation entity.
            pendulumParent.components.set(PhysicsSimulationComponent())
            // Add physics joints component to parent simulation entity.
            pendulumParent.components.set(PhysicsJointsComponent())
            
            // Rotate hinge orientation from x to z-axis.
            let hingeOrientation = simd_quatf(from: [1, 0, 0], to: [0, 0, 1])
            
            // The attachment's pin is in the center of the attachment entity.
            let attachmentPin = attachmentEntity.pins.set(
                named: "attachment_hinge",
                position: .zero,
                orientation: hingeOrientation
            )
            
            // The ball's pin is at the center of the attachment entity in local space.
            let relativeJointLocation = attachmentEntity.position(relativeTo: ballEntity)
            
            let ballPin = ballEntity.pins.set(
                named: "ball_hinge",
                position: relativeJointLocation,
                orientation: hingeOrientation
            )
            
            do {
                let revoluteJoint = PhysicsRevoluteJoint(pin0: attachmentPin, pin1: ballPin)
                try revoluteJoint.addToSimulation()
            } catch {
                print("Failed to add revolute joint to simulation: \(error)")
            }
            
        }
        
        VStack {
            Spacer()
            impulseButton
        }.padding()
    }
    
    var impulseButton: some View {
        Button(
            action: impulseButtonAction,
            label: {
                Text("Push ball").padding()
            }
        ).disabled(pushButtonDisabled)
    }
    
    /// Performs an impulse to the first pendulum's ball.
    func impulseButtonAction() {
        // Disable button, to avoid rapid pressing.
        pushButtonDisabled = true
        
        // Use the stored reference to the ball entity
        guard let ball = ballEntity else {
            print("Ball entity not found")
            return
        }
        
        // Push the first pendulum's ball.
        try? pushEntity(ball)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Re-enable button.
            pushButtonDisabled = false
        }
    }
    
    func pushEntity(_ ballEntity: Entity) throws {
        // Create a new impulse action.
        let impulseAction = ImpulseAction(
            targetEntity: .sourceEntity,
            linearImpulse: pendulumSettings.impulsePower
        )

        // Convert the impulse action to a playable animation.
        let impulseAnimation = try AnimationResource
            .makeActionAnimation(for: impulseAction)

        // Play the impulse action, which is in the form of an animation resource.
        ballEntity.playAnimation(impulseAnimation)
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
        ballEntity.name = "ball"
        ballEntity.components.set(CollisionComponent(shapes: [.generateSphere(radius: pendulumSettings.ballRadius)]))
        
        let ballCollisionShape = ShapeResource.generateSphere(
            radius: pendulumSettings.ballRadius
        )

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
