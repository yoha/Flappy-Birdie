//
//  GameScene.swift
//  Flappy Birdie
//
//  Created by Yohannes Wijaya on 8/18/15.
//  Copyright (c) 2015 Yohannes Wijaya. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    //**************************
    // MARK: - Stored Properties
    //**************************
    
    var birdie: SKSpriteNode!
    var skyColor = SKColor()
    
    let gravityValue: CGFloat = -5.0
    let spriteSizeScale: CGFloat = 2.0
    
    //*************************
    // MARK: - Methods Override
    //*************************
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //**************
        // MARK: Physics
        //**************
        
        self.physicsWorld.gravity = CGVectorMake(0.0, self.gravityValue)
        
        //**********
        // MARK: Sky
        //**********
        
        self.skyColor = UIColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
        self.backgroundColor = self.skyColor
        
        //*************
        // MARK: Birdie
        //*************
        
        // textures
        let birdieTexture1 = SKTexture(imageNamed: "birdie1")
        birdieTexture1.filteringMode = SKTextureFilteringMode.Nearest
        let birdieTexture2 = SKTexture(imageNamed: "birdie2")
        birdieTexture2.filteringMode = SKTextureFilteringMode.Nearest
        
        // flapping animation
        let birdieFlappingAnimation = SKAction.animateWithTextures([birdieTexture1, birdieTexture2], timePerFrame: 0.2)
        let repeatBirdieFlappingAnimationForever = SKAction.repeatActionForever(birdieFlappingAnimation)
        
        // instantiation
        self.birdie = SKSpriteNode(texture: birdieTexture1)
        self.birdie.setScale(self.spriteSizeScale)
        self.birdie.position = CGPointMake(self.frame.size.width / 2.5, CGRectGetMidY(self.frame))
        self.birdie.runAction(repeatBirdieFlappingAnimationForever)
        
        // physics
        self.birdie.physicsBody = SKPhysicsBody(circleOfRadius: self.birdie.size.height / 2)
        self.birdie.physicsBody!.dynamic = true
        self.birdie.physicsBody!.allowsRotation = false
        
        self.addChild(self.birdie)
        
        //*************
        // MARK: Ground
        //*************
        
        let groundTexture = SKTexture(imageNamed: "ground")
        self.generateContinuousSpriteNodes(groundTexture, action: self.animateContinuousTextures(groundTexture, period: 0.02))
        
        //**************
        // MARK: Skyline
        //**************
        
        let skylineTexture = SKTexture(imageNamed: "skyline")
        self.generateContinuousSpriteNodes(skylineTexture, action: self.animateContinuousTextures(skylineTexture, period: 0.1), groundTextureHeight: groundTexture.size().height)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
 
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    //***********************
    // MARK: - Custom Methods
    //***********************

    func generateContinuousSpriteNodes(texture: SKTexture, action: SKAction, groundTextureHeight: CGFloat = 0) {
        /**
        print(self.frame.size.width)
        print(texture.size().width)
        print(texture.size().height)
        print(2 + Int(self.frame.size.width / (texture.size().width * 2)))
        print("---")
        **/
        texture.filteringMode = SKTextureFilteringMode.Nearest
        for index in 0 ..< 2 + Int(self.frame.size.width / (texture.size().width * 2)) {
            let spriteNode = SKSpriteNode(texture: texture)
            spriteNode.setScale(self.spriteSizeScale)
            spriteNode.position = CGPointMake(CGFloat(index) * spriteNode.size.width, spriteNode.size.height / 2 + groundTextureHeight * 2)
            spriteNode.runAction(action)
            self.addChild(spriteNode)
        }
    }
    
    func animateContinuousTextures(texture: SKTexture, period: NSTimeInterval) -> SKAction {
        print(texture.description)
        let animateInitialSprite = SKAction.moveByX(-texture.size().width * 2.0, y: 0.0, duration: period * Double(texture.size().width) * 2)
        let animateSubsequentSprite = SKAction.moveByX(texture.size().width * 2.0, y: 0.0, duration: 0)
        let animateSpriteForever = SKAction.repeatActionForever(SKAction.sequence([animateInitialSprite, animateSubsequentSprite]))
        return animateSpriteForever
    }
}
