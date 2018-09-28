//
//  GameScene.swift
//  TapDrive
//
//  Created by Sylwester Pilarz on 12.09.2018.
//  Copyright © 2018 Intengine. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var leftCar = SKSpriteNode()
    var rightCar = SKSpriteNode()
    
    var canMove = false
    
    var leftCarToMoveLeft = true
    var rightCarToMoveRight = true
    
    var leftCarAtRight = false
    var rightCarAtLeft = false
    
    var centerPoint : CGFloat!
    var score = 0
    
    var countDown = 1
    var stopEverything = true // obviously
    var scoreText = SKLabelNode()
    
    let leftCarMinimumX : CGFloat = -280
    let leftCarMaximumX : CGFloat = -100
    
    let rightCarMinimumX : CGFloat = 100
    let rightCarMaximumX : CGFloat = 280
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setUp()
        physicsWorld.contactDelegate = self
        Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(GameScene.createRoadStrip), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.startCountDown), userInfo: nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 0, secondNumber: 1.8)), target: self, selector: #selector(GameScene.leftTraffic), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 0, secondNumber: 1.8)), target: self, selector: #selector(GameScene.rightTraffic), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(2), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)
        
        let deadTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: deadTime) {
            Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.increaseScore), userInfo: nil, repeats: true)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if canMove {
            move(leftSide : leftCarToMoveLeft)
            move(rightSide: rightCarToMoveRight)
        }
        showRoadStrip()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "leftCar" || contact.bodyA.node?.name == "rightCar" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        firstBody.node?.removeFromParent()
        afterCollision()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            if touchLocation.x > centerPoint {
                if rightCarAtLeft {
                    rightCarAtLeft = false
                    rightCarToMoveRight = true
                } else {
                    rightCarAtLeft = true
                    rightCarToMoveRight = false
                }
            } else {
                if leftCarAtRight {
                    leftCarAtRight = false
                    leftCarToMoveLeft = true
                } else {
                    leftCarAtRight = true
                    leftCarToMoveLeft = false
                }
            }
            canMove = true
        }
    }
    
    func setUp() {
        leftCar = self.childNode(withName: "leftCar") as! SKSpriteNode
        rightCar = self.childNode(withName: "rightCar") as! SKSpriteNode
        centerPoint = self.frame.size.width / self.frame.size.height
        
        leftCar.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        leftCar.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER
        leftCar.physicsBody?.collisionBitMask = 0
        
        rightCar.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        rightCar.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER_1
        rightCar.physicsBody?.collisionBitMask = 0

        let scorePanel = SKShapeNode(rect: CGRect(x: -self.size.width / 2 + 70, y: self.size.height / 2 - 130, width: 180, height: 80), cornerRadius: 20)
        scorePanel.zPosition = 4
        scorePanel.fillColor = SKColor.black.withAlphaComponent(0.3)
        scorePanel.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(scorePanel)

        scoreText.name = "score"
        scoreText.fontName = "Helvetica Neue Bold"
        scoreText.text = "0"
        scoreText.fontColor = SKColor.white
        scoreText.position = CGPoint(x: -self.size.width / 2 + 160, y: self.size.height / 2 - 110)
        scoreText.fontSize = 50
        scoreText.zPosition = 4
        addChild(scoreText)
    }
    
    @objc func createRoadStrip() {
        let leftRoadStrip = SKShapeNode(rectOf: CGSize(width: 10, height: 40))
        leftRoadStrip.strokeColor = SKColor.white
        leftRoadStrip.fillColor = SKColor.white
        leftRoadStrip.alpha = 0.4
        leftRoadStrip.name = "leftRoadStrip"
        leftRoadStrip.zPosition = 10
        leftRoadStrip.position.x = -187.5
        leftRoadStrip.position.y = 700
        addChild(leftRoadStrip)
        
        let rightRoadStrip = SKShapeNode(rectOf: CGSize(width: 10, height: 40))
        rightRoadStrip.strokeColor = SKColor.white
        rightRoadStrip.fillColor = SKColor.white
        rightRoadStrip.alpha = 0.4
        rightRoadStrip.name = "rightRoadStrip"
        rightRoadStrip.zPosition = 10
        rightRoadStrip.position.x = 187.5
        rightRoadStrip.position.y = 700
        addChild(rightRoadStrip)
    }
    
    func showRoadStrip() {
        enumerateChildNodes(withName: "leftRoadStrip", using: {(roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= 30
        })
        
        enumerateChildNodes(withName: "rightRoadStrip", using: {(roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= 30
        })
        
        enumerateChildNodes(withName: "redCar", using: {(leftCar, stop) in
            let car = leftCar as! SKSpriteNode
            car.position.y -= 15
        })
        
        enumerateChildNodes(withName: "greenCar", using: {(rightCar, stop) in
            let car = rightCar as! SKSpriteNode
            car.position.y -= 15
        })
    }
    
    @objc func removeItems() {
        for child in children {
            if child.position.y < -self.size.height - 100 {
                child.removeFromParent()
            }
        }
    }
    
    func move(leftSide : Bool) {
        if leftSide {
            leftCar.position.x -= 20
            if leftCar.position.x < leftCarMinimumX {
                leftCar.position.x = leftCarMinimumX
            }
        } else {
            leftCar.position.x += 20
            if leftCar.position.x > leftCarMaximumX {
                leftCar.position.x = leftCarMaximumX
            }
        }
    }
    
    func move(rightSide : Bool) {
        if rightSide {
            rightCar.position.x -= 20
            if rightCar.position.x < rightCarMinimumX {
                rightCar.position.x = rightCarMinimumX
            }
        } else {
            rightCar.position.x += 20
            if rightCar.position.x > rightCarMaximumX {
                rightCar.position.x = rightCarMaximumX
            }
        }
    }
    
    @objc func leftTraffic() {
        if !stopEverything {
            let leftTrafficItem : SKSpriteNode!
            let randomNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
            switch Int(randomNumber) {
            case 1...4:
                leftTrafficItem = SKSpriteNode(imageNamed: "redCar")
                leftTrafficItem.name = "redCar"
                break
            case 5...8:
                leftTrafficItem = SKSpriteNode(imageNamed: "greenCar")
                leftTrafficItem.name = "greenCar"
                break
            default:
                leftTrafficItem = SKSpriteNode(imageNamed: "redCar")
                leftTrafficItem.name = "redCar"
            }
            leftTrafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            leftTrafficItem.zPosition = 10
            
            let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
            switch Int(randomNum) {
            case 1...4:
                leftTrafficItem.position.x = -280
                break
            case 5...10:
                leftTrafficItem.position.x = -100
                break
            default:
                leftTrafficItem.position.x = -280
            }
            leftTrafficItem.position.y = 700
            leftTrafficItem.physicsBody = SKPhysicsBody(circleOfRadius: leftTrafficItem.size.height / 2)
            leftTrafficItem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER
            leftTrafficItem.physicsBody?.collisionBitMask = 0
            leftTrafficItem.physicsBody?.affectedByGravity = false
            addChild(leftTrafficItem)
        }
    }
    
    @objc func rightTraffic() {
        if !stopEverything {
            let rightTrafficItem : SKSpriteNode!
            let randomNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
            switch Int(randomNumber) {
            case 1...4:
                rightTrafficItem = SKSpriteNode(imageNamed: "redCar")
                rightTrafficItem.name = "redCar"
                break
            case 5...8:
                rightTrafficItem = SKSpriteNode(imageNamed: "greenCar")
                rightTrafficItem.name = "greenCar"
                break
            default:
                rightTrafficItem = SKSpriteNode(imageNamed: "redCar")
                rightTrafficItem.name = "redCar"
            }
            rightTrafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            rightTrafficItem.zPosition = 10
            
            let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
            switch Int(randomNum) {
            case 1...4:
                rightTrafficItem.position.x = 280
                break
            case 5...10:
                rightTrafficItem.position.x = 100
                break
            default:
                rightTrafficItem.position.x = 280
            }
            rightTrafficItem.position.y = 700
            rightTrafficItem.physicsBody = SKPhysicsBody(circleOfRadius: rightTrafficItem.size.height / 2)
            rightTrafficItem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER_1
            rightTrafficItem.physicsBody?.collisionBitMask = 0
            rightTrafficItem.physicsBody?.affectedByGravity = false
            addChild(rightTrafficItem)
        }
    }
    
    func afterCollision() {
        let menuScene = SKScene(fileNamed: "GameMenu")
        menuScene?.scaleMode = .aspectFill
        view?.presentScene(menuScene!, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(2)))
    }
    
    @objc func startCountDown() {
        if countDown > 0 {
            if countDown < 4 {
                let countDownLabel = SKLabelNode()
                countDownLabel.fontName = "Helvetica Neue Thin"
                countDownLabel.fontColor = SKColor.white
                countDownLabel.fontSize = 200
                countDownLabel.text = String(countDown)
                countDownLabel.position = CGPoint(x: 0, y: 0)
                countDownLabel.zPosition = 300
                countDownLabel.name = "cLabel"
                countDownLabel.horizontalAlignmentMode = .center
                addChild(countDownLabel)
                
                let deadTime = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: deadTime, execute: {
                    countDownLabel.removeFromParent()
                })
            }
            countDown += 1
            if countDown == 4 {
                self.stopEverything = false
            }
        }
    }
    
    @objc func increaseScore() {
        if !stopEverything {
            score += 1
            scoreText.text = String(score)
        }
    }
}
