import SwiftUI
import SpriteKit

struct PlayView: View {
    
    @EnvironmentObject var livesManager: LivesManager
    @State var gameOver = false
    
    @State var playScene: PlayScene = PlayScene()
    
    @State var starsCount: Int = 0 {
        didSet {
            UserDefaults.standard.set(starsCount, forKey: "stars_count")
        }
    }
    
    var body: some View {
        VStack {
            if !gameOver {
                SpriteView(scene: playScene)
                    .ignoresSafeArea()
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("game_over"), object: nil), perform: { _ in
                        let bestScore = UserDefaults.standard.integer(forKey: "best_score")
                        if playScene.score > bestScore {
                            UserDefaults.standard.set(playScene.score, forKey: "best_score")
                        }
                        starsCount += 5
                        livesManager.loseLife()
                        withAnimation(.linear(duration: 0.4)) {
                            gameOver = true
                        }
                    })
            } else {
                GameOverScreenView(score: playScene.score) {
                    playScene = PlayScene()
                    withAnimation(.linear(duration: 0.4)) {
                        gameOver = false
                    }
                }
            }
        }
    }
}

#Preview {
    PlayView()
        .environmentObject(LivesManager())
}
