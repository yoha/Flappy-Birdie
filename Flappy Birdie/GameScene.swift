//
//  GameScene.swift
//  Flappy Birdie
//
//  Created by Yohannes Wijaya on 8/18/15.
//  Copyright (c) 2015 Yohannes Wijaya. All rights reserved.
//
//todo:
//1. investigate game crash w/ the error "skLabelNode cannot be cast to skSpriteNode" but ok on simulator.

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //**************************
    // MARK: - Stored Properties
    //**************************
    
    var skyColor: UIColor!
    
    var birdieNode: SKSpriteNode!
    var allMovingNodesExceptBirdie: SKNode!
    var justPipeNodes: SKNode!
    
    let gravityValue: CGFloat = -5.0
    let spriteSizeScale: CGFloat = 2.0
    let impulseIntensity: CGFloat = 4.0
    let verticalGapBetweenPipes: CGFloat = 100.0
    
    let birdCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let pipeCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    
    var numberOfTouchReceived = 0
    
    var score = 0 {
        didSet {
            self.scoreLabelNode.text = "\(score)"
            
            if #available(iOS 9, *) { self.scoreLabelShadowNode = self.scoreLabelNode.children.first! as! SKLabelNode }
            else { self.scoreLabelShadowNode = NSArray(array: self.scoreLabelNode.children).firstObject! as! SKLabelNode }
            self.scoreLabelShadowNode.text = "\(self.score)"
        }
    }
    var highestScore = 0 {
        didSet {
            self.highestScoreLabelNode.text = "Highest Score: \(self.highestScore)"
            
            if #available(iOS 9, *) { self.highestScoreLabelShadowNode = self.highestScoreLabelNode.children.first! as! SKLabelNode }
            else { self.highestScoreLabelShadowNode = NSArray(array: self.highestScoreLabelNode.children).firstObject! as! SKLabelNode }
            
            self.highestScoreLabelShadowNode.text = "Highest Score: \(self.highestScore)"
        }
    }
    var scoreLabelNode: SKLabelNode!
    var scoreLabelShadowNode: SKLabelNode!
    var highestScoreLabelNode: SKLabelNode!
    var highestScoreLabelShadowNode: SKLabelNode!
    
    //*************************
    // MARK: - Methods Override
    //*************************
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //**************
        // MARK: Physics
        //**************
        
        self.physicsWorld.gravity = CGVectorMake(0.0, self.gravityValue)
        self.physicsWorld.contactDelegate = self
        
        //**********
        // MARK: Sky
        //**********
        
        self.skyColor = UIColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        
        //*************************************
        // MARK: All Moving Nodes Except Birdie
        //*************************************
        
        self.allMovingNodesExceptBirdie = SKNode()
        self.addChild(self.allMovingNodesExceptBirdie)
        
        //*************
        // MARK: Birdie
        //*************
        
        // textures
        let birdieTexture1 = SKTexture(imageNamed: "birdie1")
        birdieTexture1.filteringMode = SKTextureFilteringMode.Nearest
        let birdieTexture2 = SKTexture(imageNamed: "birdie2")
        birdieTexture2.filteringMode = SKTextureFilteringMode.Nearest
        
        // flapping animation
        let birdieFlappingAnimation = SKAction.animateWithTextures([birdieTexture1, birdieTexture2], timePerFrame: 0.1)
        let repeatBirdieFlappingAnimationForever = SKAction.repeatActionForever(birdieFlappingAnimation)
        
        // instantiation
        self.birdieNode = SKSpriteNode(texture: birdieTexture1)
        self.birdieNode.setScale(self.spriteSizeScale)
        self.birdieNode.position = CGPointMake(self.frame.size.width / 2.5, CGRectGetMidY(self.frame))
        self.birdieNode.speed = 1.5
        self.birdieNode.runAction(repeatBirdieFlappingAnimationForever)
        
        // physics
        self.birdieNode.physicsBody = SKPhysicsBody(circleOfRadius: self.birdieNode.size.height / 2)
        self.birdieNode.physicsBody!.dynamic = false // <-- it'll be affected by interactions w/ the physics world
        self.birdieNode.physicsBody!.allowsRotation = false
        self.birdieNode.physicsBody!.categoryBitMask = self.birdCategory
        self.birdieNode.physicsBody!.collisionBitMask = self.worldCategory | self.pipeCategory
        self.birdieNode.physicsBody!.contactTestBitMask = self.worldCategory | self.pipeCategory
        
        self.addChild(self.birdieNode)
        
        //*************
        // MARK: Ground
        //*************
        
        // textures
        let groundTexture = SKTexture(imageNamed: "ground")
        self.generateContinuousSpriteNodesForGroundOrSkyline(groundTexture, action: self.animateContinuousTexturesForBackgroundOrSkyline(groundTexture, period: 0.02))
        
        // physics
        let ground = SKNode()
        ground.position = CGPointMake(0, groundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height * 2))
        ground.physicsBody!.dynamic = false
        ground.physicsBody!.categoryBitMask = self.worldCategory
        
        self.addChild(ground)
        
        //**************
        // MARK: Skyline
        //**************
        
        // textures
        let skylineTexture = SKTexture(imageNamed: "skyline")
        self.generateContinuousSpriteNodesForGroundOrSkyline(skylineTexture, action: self.animateContinuousTexturesForBackgroundOrSkyline(skylineTexture, period: 0.1), zPosition: -20, groundTextureHeight: groundTexture.size().height)
        
        //************
        // MARK: Pipes
        //************
        
        self.justPipeNodes = SKNode()
        
        //*************
        // MARK: Scores
        //*************
        
        self.scoreLabelNode = self.makeDropShadowLabelNodeWith(fontName: "MarkerFelt-Wide", fontSize: 60.0, yPositionOffet: 0.75, scoreText: "\(self.score)")
        self.addChild(self.scoreLabelNode)
        self.scoreLabelShadowNode = SKLabelNode()
        
        //********************
        // MARK: Highest Score
        //********************
        
        self.highestScoreLabelNode = self.makeDropShadowLabelNodeWith(fontName: "MarkerFelt-Wide", fontSize: 18.0, yPositionOffet: 0.95, scoreText: "Highest Score: \(self.highestScore)")
        self.addChild(self.highestScoreLabelNode)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //************
        // MARK: Pipes
        //************
        
        if ++self.numberOfTouchReceived == 1 {
            self.allMovingNodesExceptBirdie.addChild(self.justPipeNodes)
            self.birdieNode.physicsBody!.dynamic = true
            
            let generatePipesThenDelay = SKAction.sequence([SKAction.runBlock(self.generateTopAndBottomPipes), SKAction.waitForDuration(2.0)])
            let generatePipesThenDelayRepeatForever = SKAction.repeatActionForever(generatePipesThenDelay)
            self.runAction(generatePipesThenDelayRepeatForever)
        }
        
        if self.allMovingNodesExceptBirdie.speed > 0 {
            self.runAction(SKAction.playSoundFileNamed("flapWings.caf", waitForCompletion: true))
            self.birdieNode.physicsBody!.velocity = CGVectorMake(0.0, 0.0)
            self.birdieNode.physicsBody!.applyImpulse(CGVectorMake(0.0, self.impulseIntensity))
        }
        // if self.canRestart == true --> if self.canRestart! (unsafe) --> if self.canRestart! && self.canRestart != nil -->
//        else if self.canRestart ?? false {
//            self.resetGame()
//        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if self.allMovingNodesExceptBirdie.speed > 0 {
            self.birdieNode.zRotation = self.clamp(-1, max: 0.5, value: self.birdieNode.physicsBody!.velocity.dy * (self.birdieNode.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001))
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if self.allMovingNodesExceptBirdie.speed > 0 {
        
            // birdie has made contact w/ score entity
            if (contact.bodyA.categoryBitMask & self.scoreCategory) == self.scoreCategory || (contact.bodyB.categoryBitMask & self.scoreCategory) == self.scoreCategory {
                self.runAction(SKAction.playSoundFileNamed("score.aac", waitForCompletion: false))
                ++self.score
                
                // add some presentation spice when new score is displayed
                self.scoreLabelNode.runAction(SKAction.sequence([SKAction.scaleTo(1.5, duration: 0.1), SKAction.scaleTo(1.0, duration: 0.1)]))
            }
                
            // birdie has collided w/ the world || pipe entity
            else {
                self.allMovingNodesExceptBirdie.speed = 0
                
                // prevent landing on bottom pipe
                self.birdieNode.physicsBody!.collisionBitMask = self.worldCategory
                self.birdieNode.runAction(SKAction.rotateByAngle(CGFloat(M_PI) * self.birdieNode.position.y * 0.01, duration: NSTimeInterval(self.birdieNode.position.y * 0.003)), completion: { () -> Void in
                    self.birdieNode.speed = 0
                })
                
                // Sound crash tone & flash background if contact is detected
                self.removeActionForKey("flash")
                let flashSequenceAction = SKAction.sequence([SKAction.playSoundFileNamed("crash.mp3", waitForCompletion: false), SKAction.repeatAction(SKAction.sequence([SKAction.runBlock({self.backgroundColor = UIColor.redColor()}), SKAction.waitForDuration(0.05), SKAction.runBlock({self.backgroundColor = self.skyColor}), SKAction.waitForDuration(0.05)]), count: 4), SKAction.runBlock({self.calculateHighestScore()})])
                self.runAction(flashSequenceAction, withKey: "flash")

                let alertController = UIAlertController(title: "Game Over", message: "What's your move?", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Play again!", style: UIAlertActionStyle.Default, handler: resetGame))
                alertController.addAction(UIAlertAction(title: "Quit!", style: UIAlertActionStyle.Cancel, handler: nil))
                self.view!.window!.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    //***********************
    // MARK: - Custom Methods
    //***********************

    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if value > max { return max }
        else if value < min { return min }
        else { return value }
    }
    
    func calculateHighestScore() {
        self.highestScore = self.score > self.highestScore ? self.score : self.highestScore
    }

    // MARK: for ground / skyline
    
    func generateContinuousSpriteNodesForGroundOrSkyline(texture: SKTexture, action: SKAction, zPosition: CGFloat = 0.0, groundTextureHeight: CGFloat = 0) {
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
            self.allMovingNodesExceptBirdie.addChild(spriteNode)
        }
    }
    
    func animateContinuousTexturesForBackgroundOrSkyline(texture: SKTexture, period: NSTimeInterval) -> SKAction {
        let animateInitialSprite = SKAction.moveByX(-texture.size().width * 2.0, y: 0.0, duration: period * NSTimeInterval(texture.size().width) * 2)
        let animateSubsequentSprite = SKAction.moveByX(texture.size().width * 2.0, y: 0.0, duration: 0)
        let animateSpriteForever = SKAction.repeatActionForever(SKAction.sequence([animateInitialSprite, animateSubsequentSprite]))
        return animateSpriteForever
    }
    
    // MARK: for pipes
    
    func generateTopAndBottomPipes() {
        
        let pipeVerticalMovementRange = CGFloat(arc4random() % UInt32(self.frame.size.height / 3))
        
        // bottom pipe
        let bottomPipeNode = self.configureEachPipe("bottomPipe", verticalPipePosition: pipeVerticalMovementRange)
        
        // top pipe
        let topPipeNode = self.configureEachPipe("topPipe", verticalPipePosition: pipeVerticalMovementRange + bottomPipeNode.size.height + self.verticalGapBetweenPipes)
        
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
        
        // invisible contact node right after pipes to detect passthrough (for scoring)
        let pipesCheckpointNode = SKNode()
        pipesCheckpointNode.position = CGPointMake(bottomPipeNode.size.width + self.birdieNode.size.width / 2, CGRectGetMidY(self.frame))
        pipesCheckpointNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(bottomPipeNode.size.width, self.frame.size.height))
        pipesCheckpointNode.physicsBody!.dynamic = false
        pipesCheckpointNode.physicsBody!.categoryBitMask = self.scoreCategory
        pipesCheckpointNode.physicsBody!.contactTestBitMask = self.birdCategory
        pairOfPipesNodes.addChild(pipesCheckpointNode)

        pairOfPipesNodes.runAction(moveAndRemoveBothPipes)
        self.justPipeNodes.addChild(pairOfPipesNodes)
    }
    
    func configureEachPipe(pipeTextureNamed: String, verticalPipePosition: CGFloat) -> SKSpriteNode {
        let pipeTexture = SKTexture(imageNamed: pipeTextureNamed)
        pipeTexture.filteringMode = SKTextureFilteringMode.Nearest
        let pipeNode = SKSpriteNode(texture: pipeTexture)
        pipeNode.setScale(self.spriteSizeScale)
        pipeNode.position = CGPointMake(0, verticalPipePosition)
        pipeNode.physicsBody = SKPhysicsBody(rectangleOfSize: pipeNode.size)
        pipeNode.physicsBody!.dynamic = false
        pipeNode.physicsBody!.categoryBitMask = self.pipeCategory
        pipeNode.physicsBody!.contactTestBitMask = self.birdCategory
        return pipeNode
    }
    
    // MARK: for scoring
    
    func makeDropShadowLabelNodeWith(fontName name: String, fontSize size: CGFloat, yPositionOffet offset: CGFloat, scoreText text: String) -> SKLabelNode {
        
        let offsetX: CGFloat = 1.0
        let offsetY: CGFloat = 1.0
        
        let labelNode = SKLabelNode(fontNamed: name)
        labelNode.fontSize = size
        labelNode.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height * offset)
        labelNode.text = text
        
        let labelShadowNode = SKLabelNode(fontNamed: name)
        labelShadowNode.fontSize = labelNode.fontSize
        labelShadowNode.fontColor = UIColor.blackColor()
        labelShadowNode.position = CGPointMake(offsetX, offsetY)
        labelShadowNode.zPosition = labelNode.zPosition - 1
        labelShadowNode.text = labelNode.text!
        labelNode.addChild(labelShadowNode)
        
        return labelNode
    }
    
    // MARK: for the game
    
    func resetGame(alertAction: UIAlertAction) {
        self.birdieNode.position = CGPointMake(self.frame.size.width / 2.5, CGRectGetMidY(self.frame))
        self.birdieNode.physicsBody!.dynamic = false
        self.birdieNode.physicsBody!.velocity = CGVectorMake(0, 0)
        self.birdieNode.physicsBody!.collisionBitMask = self.worldCategory | self.pipeCategory
        self.birdieNode.zRotation = 0
        self.birdieNode.speed = 1.5
        
        self.justPipeNodes.removeAllChildren()
        self.justPipeNodes.removeFromParent()
        self.removeAllActions()
        
        self.allMovingNodesExceptBirdie.speed = 1.0
        
        self.numberOfTouchReceived = 0
        
        self.score = 0
        self.scoreLabelNode.text = "0"
        self.scoreLabelShadowNode.text = "0"
    }
}