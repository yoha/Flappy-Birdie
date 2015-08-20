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
    
    var birdieNode: SKSpriteNode!
    
    let gravityValue: CGFloat = -5.0
    let spriteSizeScale: CGFloat = 2.0
    let impulseIntensity: CGFloat = 4.5
    let verticalGapBetweenPipes: CGFloat = 100.0
    
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
        
        let skyColor = UIColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        
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
        self.birdieNode = SKSpriteNode(texture: birdieTexture1)
        self.birdieNode.setScale(self.spriteSizeScale)
        self.birdieNode.position = CGPointMake(self.frame.size.width / 2.5, CGRectGetMidY(self.frame))
        self.birdieNode.runAction(repeatBirdieFlappingAnimationForever)
        
        // physics
        self.birdieNode.physicsBody = SKPhysicsBody(circleOfRadius: self.birdieNode.size.height / 2)
        self.birdieNode.physicsBody!.dynamic = true // <-- it'll be affected by interactions w/ the physics world
        self.birdieNode.physicsBody!.allowsRotation = false
        
        self.addChild(self.birdieNode)
        
        //*************
        // MARK: Ground
        //*************
        
        let groundTexture = SKTexture(imageNamed: "ground")
        self.generateContinuousSpriteNodesForBackgroundOrSkyline(groundTexture, action: self.animateContinuousTexturesForBackgroundOrSkyline(groundTexture, period: 0.02))
        
        // physics
        let ground = SKNode()
        ground.position = CGPointMake(0, groundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height * 2))
        ground.physicsBody!.dynamic = false
        
        self.addChild(ground)
        
        //**************
        // MARK: Skyline
        //**************
        
        let skylineTexture = SKTexture(imageNamed: "skyline")
        self.generateContinuousSpriteNodesForBackgroundOrSkyline(skylineTexture, action: self.animateContinuousTexturesForBackgroundOrSkyline(skylineTexture, period: 0.1), zPosition: -20, groundTextureHeight: groundTexture.size().height)
        
        //************
        // MARK: Pipes
        //************
        
        let generatePipesThenDelay = SKAction.sequence([SKAction.runBlock(self.generateTopAndBottomPipes), SKAction.waitForDuration(2.0)])
        let generatePipesThenDelayRepeatForever = SKAction.repeatActionForever(generatePipesThenDelay)
        self.runAction(generatePipesThenDelayRepeatForever)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.birdieNode.physicsBody!.velocity = CGVectorMake(0.0, 0.0)
        self.birdieNode.physicsBody!.applyImpulse(CGVectorMake(0.0, self.impulseIntensity))
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        self.birdieNode.zRotation = self.clamp(-1, max: 0.5, value: self.birdieNode.physicsBody!.velocity.dy * (self.birdieNode.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001))
    }
    
    //***********************
    // MARK: - Custom Methods
    //***********************

    func generateContinuousSpriteNodesForBackgroundOrSkyline(texture: SKTexture, action: SKAction, zPosition: CGFloat = 0.0, groundTextureHeight: CGFloat = 0) {
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
            spriteNode.zPosition = zPosition
            spriteNode.position = CGPointMake(CGFloat(index) * spriteNode.size.width, spriteNode.size.height / 2 + groundTextureHeight * 2)
            spriteNode.runAction(action)
            self.addChild(spriteNode)
        }
    }
    
    func animateContinuousTexturesForBackgroundOrSkyline(texture: SKTexture, period: NSTimeInterval) -> SKAction {
        let animateInitialSprite = SKAction.moveByX(-texture.size().width * 2.0, y: 0.0, duration: period * NSTimeInterval(texture.size().width) * 2)
        let animateSubsequentSprite = SKAction.moveByX(texture.size().width * 2.0, y: 0.0, duration: 0)
        let animateSpriteForever = SKAction.repeatActionForever(SKAction.sequence([animateInitialSprite, animateSubsequentSprite]))
        return animateSpriteForever
    }
    
    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if value > max { return max }
        else if value < min { return min }
        else { return value }
    }
    
    func generateTopAndBottomPipes() {
        
        let pipeVerticalMovementRange = CGFloat(arc4random() % UInt32(self.frame.size.height / 3))
        
        // bottom pipe
        let bottomPipeNode = self.setupEachPipe("bottomPipe", verticalPipePosition: pipeVerticalMovementRange)
        
        // top pipe
        let topPipeNode = self.setupEachPipe("topPipe", verticalPipePosition: pipeVerticalMovementRange + bottomPipeNode.size.height + self.verticalGapBetweenPipes)
        
        // animate pipes
        let pipeHorizontalScrollingDistance = self.frame.size.width + 2 * bottomPipeNode.size.width
        let moveBothPipesHorizontally = SKAction.moveByX(-pipeHorizontalScrollingDistance, y: 0.0, duration: NSTimeInterval(0.01 * pipeHorizontalScrollingDistance))
        let removeBothPipes = SKAction.removeFromParent()
        let moveAndRemoveBothPipes = SKAction.sequence([moveBothPipesHorizontally, removeBothPipes])
        
        // both pipes combined
        let pairOfPipesNodes = SKNode()
        pairOfPipesNodes.position = CGPointMake(self.frame.size.width + bottomPipeNode.size.width, 0)
        pairOfPipesNodes.zPosition = -10
        
        pairOfPipesNodes.addChild(bottomPipeNode)
        pairOfPipesNodes.addChild(topPipeNode)
        pairOfPipesNodes.runAction(moveAndRemoveBothPipes)
        self.addChild(pairOfPipesNodes)
    }
    
    func setupEachPipe(pipeTextureNamed: String, verticalPipePosition: CGFloat) -> SKSpriteNode {
        let pipeTexture = SKTexture(imageNamed: pipeTextureNamed)
        pipeTexture.filteringMode = SKTextureFilteringMode.Nearest
        let pipeNode = SKSpriteNode(texture: pipeTexture)
        pipeNode.setScale(self.spriteSizeScale)
        pipeNode.position = CGPointMake(0, verticalPipePosition)
        pipeNode.physicsBody = SKPhysicsBody(rectangleOfSize: pipeNode.size)
        pipeNode.physicsBody!.dynamic = false
        return pipeNode
    }
}