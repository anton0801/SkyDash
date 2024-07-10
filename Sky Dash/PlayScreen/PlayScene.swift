import Foundation
import SpriteKit
import SwiftUI

class PlayScene: SKScene, SKPhysicsContactDelegate {
    
    var airplaneVelocity = CGPoint.zero
    
    override init() {
        super.init(size: CGSize(width: 750, height: 1335))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var stars = UserDefaults.standard.integer(forKey: "stars")
    private var starsLabel = SKLabelNode(text: "")
    
    private var scoreLabel = SKLabelNode(text: "0")
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    private var passedArcs = 0
    
    var maxRotation: CGFloat = 30.0 * (.pi / 180.0)
    
    private var columnSpawner = Timer()
    private var cloudsSpawner = Timer()
    
    private var plane: SKSpriteNode = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "game_bg")
        background.size = size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)
        
        if UserDefaults.standard.bool(forKey: "mus") {
            let bgAudioNode = SKAudioNode(fileNamed: "mus_bg.wav")
            addChild(bgAudioNode)
        }
        
        let pause = SKSpriteNode(imageNamed: "pause")
        pause.position = CGPoint(x: 70, y: size.height - 70)
        pause.size = CGSize(width: 90, height: 85)
        pause.name = "pause"
        addChild(pause)
        
        let starsBalance = SKSpriteNode(imageNamed: "stars_balance")
        starsBalance.position = CGPoint(x: size.width - 130, y: size.height - 70)
        starsBalance.size = CGSize(width: 200, height: 75)
        addChild(starsBalance)
        
        starsLabel.text = "\(stars)"
        starsLabel.fontName = "Chewy-Regular"
        starsLabel.fontSize = 42
        starsLabel.fontColor = .white
        starsLabel.position = CGPoint(x: size.width - 100, y: size.height - 87)
        addChild(starsLabel)
        
        let scoreTitle = SKLabelNode(text: "Score:")
        scoreTitle.position = CGPoint(x: size.width / 2, y: size.height - 250)
        scoreTitle.fontName = "Chewy-Regular"
        scoreTitle.fontSize = 82
        scoreTitle.fontColor = .white
        addChild(scoreTitle)
        
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 340)
        scoreLabel.fontName = "Chewy-Regular"
        scoreLabel.fontSize = 82
        scoreLabel.fontColor = .white
        addChild(scoreLabel)
        
        let planeTexture = SKTexture(imageNamed: UserDefaults.standard.string(forKey: "plane_sel") ?? "base_plane")
        plane = .init(texture: planeTexture)
        plane.position = CGPoint(x: 150, y: size.height / 2)
        plane.physicsBody = SKPhysicsBody(rectangleOf: plane.size)
        plane.physicsBody?.isDynamic = true
        plane.physicsBody?.affectedByGravity = false
        plane.physicsBody?.categoryBitMask = 1
        plane.physicsBody?.collisionBitMask = 2
        plane.physicsBody?.contactTestBitMask = 2
        plane.name = "plane"
        addChild(plane)
        
        createColumns()
        
        columnSpawner = .scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            self.createColumns()
        }
        cloudsSpawner = .scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(spawnClouds), userInfo: nil, repeats: true)
    }
    
    private func createColumns() {
        if !self.isPaused {
            let random = Bool.random()
            createColumn(bottomColumn: true, random: random, count: 1)
            createColumn(bottomColumn: false, random: random, count: 2)
        }
    }
    
    private func createColumn(bottomColumn: Bool, random: Bool, count: Int) {
        let columnHeight: CGFloat
        if random {
            if bottomColumn {
                columnHeight = CGFloat.random(in: 600...700)
            } else {
                columnHeight = CGFloat.random(in: 300...400)
            }
        } else {
            
            if bottomColumn {
                columnHeight = CGFloat.random(in: 300...400)
            } else {
                columnHeight = CGFloat.random(in: 600...700)
            }
        }
        let columY: CGFloat
        if bottomColumn {
            columY = columnHeight / 2
        } else {
            columY = size.height - (columnHeight / 2)
        }
        let columnNode = SKSpriteNode(imageNamed: "column")
        columnNode.position = CGPoint(x: size.width, y: columY)
        columnNode.size = CGSize(width: 50, height: columnHeight)
        columnNode.name = "column"
        columnNode.physicsBody = SKPhysicsBody(rectangleOf: columnNode.size)
        columnNode.physicsBody?.isDynamic = false
        columnNode.physicsBody?.affectedByGravity = false
        columnNode.physicsBody?.categoryBitMask = 2
        columnNode.physicsBody?.collisionBitMask = 1
        columnNode.physicsBody?.contactTestBitMask = 1
        addChild(columnNode)
        
       var duration = 5.0
       if passedArcs >= 5 {
           duration = 4.7
       } else if passedArcs >= 10 {
           duration = 4.3
       } else if passedArcs >= 20 {
           duration = 4
       } else if passedArcs >= 30 {
           duration = 3.6
       } else if passedArcs >= 50 {
           duration = 3
       } else if passedArcs >= 100 {
           duration = 2.2
       } else if passedArcs >= 200 {
           duration = 1.5
       }
        
        if count == 2 {
            let invisibleRect = SKSpriteNode(color: .clear, size: CGSize(width: 40, height: size.height))
            invisibleRect.position = CGPoint(x: size.width, y: 0)
            invisibleRect.physicsBody = SKPhysicsBody(rectangleOf: invisibleRect.size)
            invisibleRect.physicsBody?.isDynamic = false
            invisibleRect.physicsBody?.affectedByGravity = false
            invisibleRect.physicsBody?.categoryBitMask = 3
            invisibleRect.physicsBody?.collisionBitMask = 1
            invisibleRect.physicsBody?.contactTestBitMask = 1
            addChild(invisibleRect)
            
          let columnNodeMoveAction = SKAction.move(to: CGPoint(x: -100, y: columnNode.position.y), duration: duration)
            invisibleRect.run(columnNodeMoveAction)
        }
       
        let columnNodeMoveAction = SKAction.move(to: CGPoint(x: -100, y: columnNode.position.y), duration: duration)
        columnNode.run(columnNodeMoveAction)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bA = contact.bodyA
        let bB = contact.bodyB
        
        if bA.categoryBitMask == 1 && bB.categoryBitMask == 3 ||
            bA.categoryBitMask == 3 && bB.categoryBitMask == 1 {
            let checkerBody: SKPhysicsBody
            let planeBody: SKPhysicsBody
            
            if bA.categoryBitMask == 1 {
                planeBody = bA
                checkerBody = bB
            } else {
                planeBody = bB
                checkerBody = bA
            }
            
            score += 1
            passedArcs += 1
            checkerBody.node?.removeFromParent()
        }
        
        if bA.categoryBitMask == 1 && bB.categoryBitMask == 2 ||
            bA.categoryBitMask == 2 && bB.categoryBitMask == 1  {
            self.isPaused = true
            self.columnSpawner.invalidate()
            plane.removeFromParent()
            if UserDefaults.standard.bool(forKey: "ssound") {
                run(SKAction.playSoundFileNamed("over.wav", waitForCompletion: false))
            }
            NotificationCenter.default.post(name: Notification.Name("game_over"), object: nil)
        }
    }
    
    @objc private func spawnClouds() {
        if !self.isPaused {
            let cloudR = ["clouds", "clouds_2", "clouds_3", "clouds_4", "clouds_5"].randomElement() ?? "clouds"
            let cloudY = CGFloat.random(in: (size.height - 450)...(size.height - 200))
            let cloudNode = SKSpriteNode(imageNamed: cloudR)
            cloudNode.position = CGPoint(x: size.width + cloudNode.size.width + 50, y: cloudY)
            cloudNode.zPosition = 0
            addChild(cloudNode)
            
            let moveCloud = SKAction.move(to: CGPoint(x: -200, y: cloudNode.position.y), duration: 5)
            cloudNode.run(moveCloud)
        }
    }
    
    private var tapped = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let actionUp = SKAction.move(to: CGPoint(x: plane.position.x, y: plane.position.y + 30), duration: 0.3)
        plane.zRotation = maxRotation
        plane.run(actionUp)
        tapped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tapped = false
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !self.tapped {
            plane.position.y -= 1.5
            
            plane.zRotation = -maxRotation
            
            if plane.position.y < 0 {
                NotificationCenter.default.post(name: Notification.Name("game_over"), object: nil)
            }
        }
    }
    
}

#Preview {
    VStack {
        SpriteView(scene: PlayScene())
            .ignoresSafeArea()
    }
}
