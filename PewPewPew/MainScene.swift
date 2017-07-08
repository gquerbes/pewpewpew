//
//  MainScene.swift
//  PewPewPew
//
//  Created by Gabe on 7/8/17.
//  Copyright © 2017 Fourteen66. All rights reserved.
//

import Foundation
import SpriteKit


class MainScene : SKScene, SKPhysicsContactDelegate{
    
    private var paddle : Paddle?
    private var paddleXPosition : CGFloat?
    private var paddleYPosition : CGFloat? // does not change
    private var lastUpdate : TimeInterval = 0
    private var ball : Ball?
    
    
    override func sceneDidLoad() {
        
        // create paddle
        if(paddle == nil){
            let w = (self.size.width + self.size.height) * 0.05
            self.paddle = Paddle.init(size: CGSize(width: w, height: w/4))
            
            paddleXPosition = UIScreen.main.bounds.width * -0.05
            paddleYPosition = UIScreen.main.bounds.height * -0.5
            paddle?.position = CGPoint.init(x: paddleXPosition!, y: paddleYPosition!)
          
            self.addChild(paddle!)
          
        }
        
        if(ball == nil){
            ball = Ball.init()
            ball?.position = CGPoint(x: (paddle?.position.x)!, y: UIScreen.main.bounds.height)
            
            ball?.run(SKAction.sequence([SKAction.wait(forDuration: 10.0), SKAction.removeFromParent()]))
            
            
        }
        self.physicsWorld.contactDelegate = self as SKPhysicsContactDelegate
        
        
        
    }
    // MARK: Interaction
    
    func dropBall(){
        if let newball = self.ball?.copy() as! SKSpriteNode?{
            self.addChild(newball)
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint){
       let moveAction =  SKAction.moveTo(x: pos.x, duration: 0.02)
        
        paddle?.run(moveAction)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches{self.touchDown(atPoint: t.location(in: self))}
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches{self.touchDown(atPoint: t.location(in: self))}
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if(self.lastUpdate == 0){
            self.lastUpdate = currentTime
            
        }
        
        let dt = currentTime - self.lastUpdate
        
        if(dt > 1){
            dropBall()
            self.lastUpdate = currentTime
            
            //clean up old children
            for child in self.children{
                if(!child.intersects(self) && child.position.y < (paddle?.position.y)! - 1){
                    child.removeFromParent()
                }
            }
        }

    }

    let shockWaveAction: SKAction = {
        let growAndFadeAction = SKAction.group([SKAction.scale(to: 50, duration: 0.5),
                                                SKAction.fadeOut(withDuration: 0.5)])
        
        let sequence = SKAction.sequence([growAndFadeAction,
                                          SKAction.removeFromParent()])
        
        return sequence
    }()
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.collisionImpulse > 5 &&
            contact.bodyA.node?.name == "paddle" &&
            contact.bodyB.node?.name == "ball" {
            
            let shockwave = SKShapeNode(circleOfRadius: 1)
            
            shockwave.position = contact.contactPoint
            self.addChild(shockwave)
            
            contact.bodyB.node?.name == "ball" ? contact.bodyB.node?.removeFromParent() : contact.bodyA.node?.removeFromParent()    
            shockwave.run(shockWaveAction)
        }
    }
    
}
