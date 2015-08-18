//
//  GameScene.swift
//  Flappy Birdie
//
//  Created by Yohannes Wijaya on 8/18/15.
//  Copyright (c) 2015 Yohannes Wijaya. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Stored Properties
    
    var birdie: SKSpriteNode!
    var skyColor = SKColor()
    
    let gravityValue: CGFloat = -5.0
    
    // MARK: - Methods Override
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // Physics
        self.physicsWorld.gravity = CGVectorMake(0.0, self.gravityValue)
        
        // Sky
        self.skyColor = UIColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
        self.backgroundColor = self.skyColor
        
        // Birdie
        let birdieTexture1 = SKTexture(imageNamed: "birdie1")
        birdieTexture1.filteringMode = SKTextureFilteringMode.Nearest
        let birdieTexture2 = SKTexture(imageNamed: "birdie2")
        birdieTexture2.filteringMode = SKTextureFilteringMode.Nearest
        
        let birdieFlappingAnimation = SKAction.animateWithTextures([birdieTexture1, birdieTexture2], timePerFrame: 0.2)
        let repeatBirdieFlappingAnimationForever = SKAction.repeatActionForever(birdieFlappingAnimation)
        
        self.birdie = SKSpriteNode(texture: birdieTexture1)
        self.birdie.setScale(2.0)
        self.birdie.position = CGPointMake(self.frame.size.width / 2.5, CGRectGetMidY(self.frame))
        self.birdie.runAction(repeatBirdieFlappingAnimationForever)
        self.addChild(self.birdie)
        
        // Ground
//        let groundTexture = SKTexture(imageNamed: "ground")
//        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
//        for index in 0 ..<
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
 
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
