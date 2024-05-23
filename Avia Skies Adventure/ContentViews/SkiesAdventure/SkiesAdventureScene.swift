import Foundation
import SwiftUI
import SpriteKit

class SkiesAdventureScene: SKScene, SKPhysicsContactDelegate {
    
    var skiesBack: SKSpriteNode!
    
    var plane: SKSpriteNode!
    var startGameBtn: SKSpriteNode!
    var fireBtn: SKSpriteNode!
    
    var homeBtn: SKSpriteNode!
    
    var planeMoveRight: SKSpriteNode!
    var planeMoveLeft: SKSpriteNode!
    
    var distanceLabel: SKLabelNode!
    var distance = 0 {
        didSet {
            distanceLabel.text = "\(distance) m"
        }
    }
    
    let baseObstacles = ["obstacle_bomb", "obstacle_bomb_2", "obstacle_bird"]
    
    var baseObstacleSpawnTimer = Timer()
    var planeObstacleSpawnTimer = Timer()
    var coinObstacleSpawnTimer = Timer()
    var rocketEnergySpawnTimer = Timer()
    var timeTimer = Timer()
    
    private var creditsLabel: SKLabelNode!
    private var credits = UserDefaults.standard.integer(forKey: .pointsKey) {
        didSet {
            creditsLabel.text = "\(credits)"
            UserDefaults.standard.set(credits, forKey: .pointsKey)
        }
    }
    private var earnedCoinsInThisGame = 0
    
    private var rocketFireCountLabel: SKLabelNode!
    private var rocketFireCount = 1 {
        didSet {
            rocketFireCountLabel.text = "\(rocketFireCount)"
        }
    }
    
    private var gameFinished = false {
        didSet {
            isPaused = true
            makeGameResult()
        }
    }
    
    private var gameStarted = false {
        didSet {
            if gameStarted {
                let actionMovePlane = SKAction.move(to: CGPoint(x: size.width / 2, y: plane.position.y + 150), duration: 0.5)
                plane.run(actionMovePlane)
                
                let actionFadeOut = SKAction.fadeOut(withDuration: 0.2)
                startGameBtn.run(actionFadeOut) {
                    self.startGameBtn.removeFromParent()
                }
                
                drawGameUI()
            }
        }
    }
    
    override func didMove(to view: SKView) {
        size = CGSize(width: 750, height: 1335)
        physicsWorld.contactDelegate = self
        
        drawSkiesBackground()
        drawPlane()
        drawInitialUI()
        drawUI()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if bodyA.categoryBitMask == 6 && bodyB.categoryBitMask == 2 {
            credits += 150
            earnedCoinsInThisGame += 150
            bodyA.node!.removeFromParent()
            bodyB.node!.removeFromParent()
        }
        
        if bodyA.categoryBitMask == 5 && bodyB.categoryBitMask == 1 {
            bodyA.node!.removeFromParent()
            bodyB.node!.removeFromParent()
            addSound(sound: "exp_plane")
            gameFinished = true
        } else if bodyA.categoryBitMask == 5 && bodyB.categoryBitMask == 2 {
            bodyA.node!.removeFromParent()
            bodyB.node!.removeFromParent()
            addSound(sound: "exp_plane")
            gameFinished = true
        } else if bodyA.categoryBitMask == 5 && bodyB.categoryBitMask == 3 {
            credits += 50
            earnedCoinsInThisGame += 50
            bodyB.node!.removeFromParent()
            addSound(sound: "coin")
        } else if bodyA.categoryBitMask == 5 && bodyB.categoryBitMask == 4 {
            rocketFireCount += 1
            bodyB.node!.removeFromParent()
        }
    }
    
    @objc private func baseObstacleSpawn() {
        if !isPaused {
            let obstacleBaseRandom = baseObstacles.randomElement() ?? "obstacle_bomb"
            let xPos = Int.random(in: 50...Int(size.width) - 50)
            let nodeObstacle = SKSpriteNode(imageNamed: obstacleBaseRandom)
            nodeObstacle.size = CGSize(width: 50, height: 45)
            nodeObstacle.position = CGPoint(x: CGFloat(xPos), y: size.height)
            nodeObstacle.physicsBody = SKPhysicsBody(rectangleOf: nodeObstacle.size)
            nodeObstacle.physicsBody?.isDynamic = true
            nodeObstacle.physicsBody?.affectedByGravity = false
            nodeObstacle.physicsBody?.categoryBitMask = 1
            nodeObstacle.physicsBody?.contactTestBitMask = 5
            nodeObstacle.physicsBody?.collisionBitMask = 5
            nodeObstacle.name = obstacleBaseRandom
            addChild(nodeObstacle)
            
            let actionMoveDown = SKAction.move(to: CGPoint(x: xPos, y: -100), duration: TimeInterval(7 - (distance / 2000)))
            nodeObstacle.run(actionMoveDown) {
                nodeObstacle.removeFromParent()
            }
        }
    }
    
    @objc private func planeObstacleSpawn() {
        if !isPaused {
            let xPos = Int.random(in: 50...Int(size.width) - 50)
            let nodeObstacle = SKSpriteNode(imageNamed: "obstacle_plane")
            nodeObstacle.size = CGSize(width: 140, height: 130)
            nodeObstacle.position = CGPoint(x: CGFloat(xPos), y: size.height)
            nodeObstacle.physicsBody = SKPhysicsBody(rectangleOf: nodeObstacle.size)
            nodeObstacle.physicsBody?.isDynamic = true
            nodeObstacle.physicsBody?.affectedByGravity = false
            nodeObstacle.physicsBody?.categoryBitMask = 2
            nodeObstacle.physicsBody?.contactTestBitMask = 5 | 6
            nodeObstacle.physicsBody?.collisionBitMask = 5 | 6
            nodeObstacle.name = "obstacle_plane"
            addChild(nodeObstacle)
            
            let actionMoveDown = SKAction.move(to: CGPoint(x: xPos, y: -100), duration: TimeInterval(7 - (distance / 2000)))
            nodeObstacle.run(actionMoveDown) {
                nodeObstacle.removeFromParent()
            }
        }
    }
    
    @objc private func coinSpawn() {
        if !isPaused {
            let xPos = Int.random(in: 50...Int(size.width) - 50)
            let nodeCoin = SKSpriteNode(imageNamed: "coin")
            nodeCoin.size = CGSize(width: 40, height: 35)
            nodeCoin.position = CGPoint(x: CGFloat(xPos), y: size.height)
            nodeCoin.physicsBody = SKPhysicsBody(rectangleOf: nodeCoin.size)
            nodeCoin.physicsBody?.isDynamic = true
            nodeCoin.physicsBody?.affectedByGravity = false
            nodeCoin.physicsBody?.categoryBitMask = 3
            nodeCoin.physicsBody?.contactTestBitMask = 5
            nodeCoin.physicsBody?.collisionBitMask = 5
            nodeCoin.name = "coin"
            addChild(nodeCoin)
            
            let actionMoveDown = SKAction.move(to: CGPoint(x: xPos, y: -100), duration: TimeInterval(7 - (distance / 2000)))
            nodeCoin.run(actionMoveDown) {
                nodeCoin.removeFromParent()
            }
        }
    }
    
    @objc private func timeDistance() {
        if !isPaused {
            distance += 25
        }
    }
    
    private func drawGameUI() {
        fireBtn = SKSpriteNode(imageNamed: "fire_btn")
        fireBtn.position = CGPoint(x: size.width / 2, y: 120)
        addChild(fireBtn)
        
        distanceLabel = SKLabelNode(text: "0 m")
        distanceLabel.position = CGPoint(x: size.width / 2, y: 40)
        distanceLabel.fontName = "CarterOne"
        distanceLabel.fontSize = 32
        distanceLabel.fontColor = .white
        addChild(distanceLabel)
        
        baseObstacleSpawnTimer = .scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(baseObstacleSpawn), userInfo: nil, repeats: true)
        planeObstacleSpawnTimer = .scheduledTimer(timeInterval: 5, target: self, selector: #selector(planeObstacleSpawn), userInfo: nil, repeats: true)
        coinObstacleSpawnTimer = .scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(coinSpawn), userInfo: nil, repeats: true)
        rocketEnergySpawnTimer = .scheduledTimer(timeInterval: 10, target: self, selector: #selector(rocketEnergySpawn), userInfo: nil, repeats: true)
        timeTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeDistance), userInfo: nil, repeats: true)
    }
    
    @objc private func rocketEnergySpawn() {
        if !isPaused {
            let xPos = Int.random(in: 50...Int(size.width) - 50)
            let nodeEnergy = SKSpriteNode(imageNamed: "rocket_energy")
            nodeEnergy.size = CGSize(width: 35, height: 50)
            nodeEnergy.position = CGPoint(x: CGFloat(xPos), y: size.height)
            nodeEnergy.physicsBody = SKPhysicsBody(rectangleOf: nodeEnergy.size)
            nodeEnergy.physicsBody?.isDynamic = true
            nodeEnergy.physicsBody?.affectedByGravity = false
            nodeEnergy.physicsBody?.categoryBitMask = 4
            nodeEnergy.physicsBody?.contactTestBitMask = 5
            nodeEnergy.physicsBody?.collisionBitMask = 5
            nodeEnergy.name = "rocket_energy"
            addChild(nodeEnergy)
            
            let actionMoveDown = SKAction.move(to: CGPoint(x: xPos, y: -100), duration: TimeInterval(7 - (distance / 2000)))
            nodeEnergy.run(actionMoveDown) {
                nodeEnergy.removeFromParent()
            }
        }
    }
    
    private func fire() {
        addSound(sound: "launch_rocket")
        let nodeBullet = SKSpriteNode(imageNamed: "rocket_bullet")
        nodeBullet.position = plane.position
        nodeBullet.physicsBody = SKPhysicsBody(rectangleOf: nodeBullet.size)
        nodeBullet.physicsBody?.isDynamic = true
        nodeBullet.physicsBody?.affectedByGravity = false
        nodeBullet.physicsBody?.categoryBitMask = 6
        nodeBullet.physicsBody?.contactTestBitMask = 2
        nodeBullet.physicsBody?.collisionBitMask = 2
        addChild(nodeBullet)
        
        let actionMoveUp = SKAction.move(to: CGPoint(x: plane.position.x, y: size.height + 100), duration: 3)
        nodeBullet.run(actionMoveUp) {
            nodeBullet.removeFromParent()
        }
    }
    
    private func drawSkiesBackground() {
        skiesBack = SKSpriteNode(imageNamed: "skies_adventure_bg")
        skiesBack.size = size
        skiesBack.position = centerPoint()
        addChild(skiesBack)
        addBackMusic(node: skiesBack)
    }
    
    private func drawPlane() {
        plane = SKSpriteNode(imageNamed: UserDefaults.standard.string(forKey: .selectedPlaneKey) ?? "plane_base")
        plane.position = CGPoint(x: size.width / 2, y: 200)
        plane.size = CGSize(width: 150, height: 150)
        plane.physicsBody = SKPhysicsBody(rectangleOf: plane.size)
        plane.physicsBody?.isDynamic = false
        plane.physicsBody?.affectedByGravity = false
        plane.physicsBody?.categoryBitMask = 5
        plane.physicsBody?.contactTestBitMask = 1 | 2 | 3 | 4
        plane.physicsBody?.collisionBitMask = 1 | 2 | 3 | 4
        plane.name = "plane"
        addChild(plane)
    }
    
    private func centerPoint() -> CGPoint {
        return CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    private func drawInitialUI() {
        startGameBtn = SKSpriteNode(imageNamed: "start_game_btn")
        startGameBtn.position = CGPoint(x: size.width / 2, y: 80)
        addChild(startGameBtn)
    }
    
    private func drawUI() {
        homeBtn = SKSpriteNode(imageNamed: "home")
        homeBtn.position = CGPoint(x: 60, y: size.height - 120)
        homeBtn.size = CGSize(width: 80, height: 70)
        addChild(homeBtn)
        
        let creditsLabelBg = SKSpriteNode(imageNamed: "label_bg")
        creditsLabelBg.position = CGPoint(x: size.width - 120, y: size.height - 120)
        creditsLabelBg.size = CGSize(width: 240, height: 50)
        addChild(creditsLabelBg)
        
        creditsLabel = SKLabelNode(text: "\(credits)")
        creditsLabel.position = CGPoint(x: size.width - 120, y: size.height - 133)
        creditsLabel.fontName = "CarterOne"
        creditsLabel.fontSize = 32
        creditsLabel.fontColor = .white
        addChild(creditsLabel)
        
        let coinIcon = SKSpriteNode(imageNamed: "coin")
        coinIcon.position = CGPoint(x: size.width - 230, y: size.height - 120)
        coinIcon.size = CGSize(width: 70, height: 60)
        addChild(coinIcon)
        
        let rocketsLabelBg = SKSpriteNode(imageNamed: "label_bg")
        rocketsLabelBg.position = CGPoint(x: size.width - 90, y: size.height - 190)
        rocketsLabelBg.size = CGSize(width: 180, height: 50)
        addChild(rocketsLabelBg)
        
        rocketFireCountLabel = SKLabelNode(text: "\(rocketFireCount)")
        rocketFireCountLabel.position = CGPoint(x: size.width - 80, y: size.height - 200)
        rocketFireCountLabel.fontName = "CarterOne"
        rocketFireCountLabel.fontSize = 24
        rocketFireCountLabel.fontColor = .black
        addChild(rocketFireCountLabel)
        
        let rocketIcon = SKSpriteNode(imageNamed: "rocket_label")
        rocketIcon.position = CGPoint(x: size.width - 180, y: size.height - 195)
        rocketIcon.size = CGSize(width: 50, height: 70)
        addChild(rocketIcon)
        
        planeMoveLeft = SKSpriteNode(imageNamed: "move_left")
        planeMoveLeft.position = CGPoint(x: size.width / 2 - 200, y: 200)
        planeMoveLeft.size = CGSize(width: 80, height: 70)
        addChild(planeMoveLeft)
        
        planeMoveRight = SKSpriteNode(imageNamed: "move_right")
        planeMoveRight.position = CGPoint(x: size.width / 2 + 200, y: 200)
        planeMoveRight.size = CGSize(width: 80, height: 70)
        addChild(planeMoveRight)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(startGameBtn) {
            gameStarted = true
            return
        }
        
        if objects.contains(homeBtn) {
            NotificationCenter.default.post(name: Notification.Name("home"), object: nil, userInfo: nil)
            return
        }
        
        if gameStarted {
            if objects.contains(planeMoveLeft) {
                if plane.position.x - 50 > 0 {
                    let actionMoveLeft = SKAction.move(to: CGPoint(x: plane.position.x - 50, y: plane.position.y), duration: 0.4)
                                plane.run(actionMoveLeft)
                }
                return
            }
            
            if objects.contains(planeMoveRight) {
                if plane.position.x + 50 < size.width {
                    let actionMoveLeft = SKAction.move(to: CGPoint(x: plane.position.x + 50, y: plane.position.y), duration: 0.4)
                                plane.run(actionMoveLeft)
                }
                return
            }
            
            if objects.contains(fireBtn) {
                if rocketFireCount > 0 {
                    rocketFireCount -= 1
                    fire()
                }
                return
            }
        }
        
        if gameFinished {
            if objects.contains(resultRestartGameBtn) {
                restartGame()
                return
            }
            
            if objects.contains(resultGameHomeBtn) {
                NotificationCenter.default.post(name: Notification.Name("home"), object: nil, userInfo: nil)
                return
            }
        }
    }
    
    private func addSound(sound: String) {
        if UserDefaults.standard.bool(forKey: .soundsKey) {
            let soundNode = SKAudioNode(fileNamed: sound)
            addChild(soundNode)
        }
    }
    
    private func addBackMusic(node: SKNode) {
        if UserDefaults.standard.bool(forKey: .musicKey) {
            let soundNode = SKAudioNode(fileNamed: "fon")
            node.addChild(soundNode)
        }
    }
    
    private var resultGameHomeBtn: SKSpriteNode!
    private var resultRestartGameBtn: SKSpriteNode!
    
    private func makeGameResult() {
        if distance > UserDefaults.standard.integer(forKey: .bestScore) {
            UserDefaults.standard.set(distance, forKey: .bestScore)
        }
        
        NotificationCenter.default.post(name: Notification.Name("claim_coins"), object: nil, userInfo: [
            "credits": earnedCoinsInThisGame])
        
        let gameResultBg = SKSpriteNode(imageNamed: "game_result_bg")
        gameResultBg.position = centerPoint()
        gameResultBg.size = CGSize(width: size.width, height: 450)
        addChild(gameResultBg)
        
        let gameResultTitle = SKLabelNode(text: "YOU DIED")
        gameResultTitle.fontColor = .red
        gameResultTitle.fontName = "CarterOne"
        gameResultTitle.fontSize = 52
        gameResultTitle.position = CGPoint(x: size.width / 2, y: size.height / 2 + 170)
        addChild(gameResultTitle)
        
        let gameDistanceResult = SKLabelNode(text: "score: \(distance) m")
        gameDistanceResult.fontColor = .white
        gameDistanceResult.fontName = "CarterOne"
        gameDistanceResult.fontSize = 38
        gameDistanceResult.position = CGPoint(x: 160, y: size.height / 2 + 120)
        addChild(gameDistanceResult)
        
        let bestScore = SKLabelNode(text: "best score: \(UserDefaults.standard.integer(forKey: .bestScore)) m")
        bestScore.fontColor = .white
        bestScore.fontName = "CarterOne"
        bestScore.fontSize = 38
        bestScore.position = CGPoint(x: 200, y: size.height / 2 + 40)
        addChild(bestScore)
        
        let earnedTitle = SKLabelNode(text: "earned: ")
        earnedTitle.fontColor = .white
        earnedTitle.fontName = "CarterOne"
        earnedTitle.fontSize = 38
        earnedTitle.position = CGPoint(x: 140, y: size.height / 2 - 40)
        addChild(earnedTitle)
        
        let earnedValue = SKLabelNode(text: "\(earnedCoinsInThisGame)")
        earnedValue.fontColor = .white
        earnedValue.fontName = "CarterOne"
        earnedValue.fontSize = 38
        earnedValue.position = CGPoint(x: 240, y: size.height / 2 - 40)
        addChild(earnedValue)
        
        let earnedCoinsIcon = SKSpriteNode(imageNamed: "coin")
        earnedCoinsIcon.size = CGSize(width: 50, height: 40)
        earnedCoinsIcon.position = CGPoint(x: 340, y: size.height / 2 - 30)
        addChild(earnedCoinsIcon)
        
        resultGameHomeBtn = SKSpriteNode(imageNamed: "home")
        resultGameHomeBtn.position = CGPoint(x: size.width / 2 - 90, y: size.height / 2 - 140)
        resultGameHomeBtn.size = CGSize(width: 80, height: 70)
        addChild(resultGameHomeBtn)
        
        resultRestartGameBtn = SKSpriteNode(imageNamed: "restart")
        resultRestartGameBtn.position = CGPoint(x: size.width / 2 + 90, y: size.height / 2 - 140)
        resultRestartGameBtn.size = CGSize(width: 80, height: 70)
        addChild(resultRestartGameBtn)
    }
    
    private func restartGame() {
        let scene = SkiesAdventureScene()
        view?.presentScene(scene)
    }
    
}

#Preview {
    VStack {
        SpriteView(scene: SkiesAdventureScene())
            .ignoresSafeArea()
    }
}
