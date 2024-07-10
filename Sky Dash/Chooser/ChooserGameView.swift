import SwiftUI

struct ChooserGameView: View {
    
    @StateObject var livesManager = LivesManager()
    @State var toGameAction = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        ForEach(1...3, id: \.self) { liveIndex in
                            if livesManager.lives < liveIndex {
                                Image("life_off")
                            } else {
                                Image("life")
                            }
                        }
                    }
                    if livesManager.lives < 3 {
                        Text("\(livesManager.formattedTime(from: livesManager.nextLifeIn))")
                            .font(.custom("Chewy-Regular", size: 52))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                Text("BEST SCORE:\n")
                    .font(.custom("Chewy-Regular", size: 52))
                    .foregroundColor(Color.init(red: 1, green: 216/255, blue: 11/255))
                HStack {
                    Image("trophy")
                        .padding(.trailing)
                    Text("\(UserDefaults.standard.integer(forKey: "best_score"))")
                        .font(.custom("Chewy-Regular", size: 52)) 
                        .foregroundColor(Color.init(red: 1, green: 216/255, blue: 11/255))
                    Image("trophy")
                        .padding(.leading)
                }
                
                Spacer()
                
                Button {
                    if livesManager.lives > 0 {
                        toGameAction = true
                    }
                } label: {
                    Image("play")
                }
                
                NavigationLink(destination: PlayView()
                    .environmentObject(livesManager)
                    .navigationBarBackButtonHidden(true), isActive: $toGameAction) {
                    
                }
                
                Spacer()
                
                HStack {
                    NavigationLink(destination: SettingsV()
                        .navigationBarBackButtonHidden(true)) {
                        Image("settings")
                    }
                    .padding(.trailing)
                    exitButton
                    NavigationLink(destination: PlaneSkinsGameView()
                        .navigationBarBackButtonHidden(true)) {
                        Image("store")
                    }
                    .padding(.leading)
                }
            }
            .background(
                Image("ch_image")
                    .resizable()
                    .frame(
                        minWidth: UIScreen.main.bounds.width,
                        minHeight: UIScreen.main.bounds.height
                    )
                    .ignoresSafeArea()
            )
            .onAppear {
                
            }
        }
    }
    
    private var exitButton: some View {
        Button {
            exit(0)
        } label: {
            Image("exit")
        }
    }
    
}

#Preview {
    ChooserGameView()
}

class LivesManager: ObservableObject {
    static let shared = LivesManager()
    
    @Published private(set) var lives: Int
    @Published private(set) var nextLifeIn: TimeInterval
    private var timer: Timer?
    
    private let maxLives = 3
    private let lifeRestoreInterval: TimeInterval = 15 * 60 // 15 минут
    private let livesKey = "lifes_available"
    private let lastLifeLostKey = "lastLifeLost"
    
    init() {
        let savedLives = UserDefaults.standard.integer(forKey: livesKey)
        let lastLifeLost = UserDefaults.standard.double(forKey: lastLifeLostKey)
        let now = Date().timeIntervalSince1970
        
        if savedLives > 0 {
            self.lives = savedLives
            self.nextLifeIn = max(0, lifeRestoreInterval - (now - lastLifeLost))
            restoreLives()
        } else {
            self.lives = maxLives
            self.nextLifeIn = lifeRestoreInterval
        }
        
        startTimer()
    }
    
    func loseLife() {
        if lives > 0 {
            lives -= 1
            UserDefaults.standard.set(lives, forKey: livesKey)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastLifeLostKey)
            if lives < maxLives {
                nextLifeIn = lifeRestoreInterval
                startTimer()
            }
        }
    }
    
    private func restoreLives() {
        let lastLifeLost = UserDefaults.standard.double(forKey: lastLifeLostKey)
        let now = Date().timeIntervalSince1970
        let elapsedTime = now - lastLifeLost
        
        if elapsedTime >= lifeRestoreInterval {
            let livesToRestore = Int(elapsedTime / lifeRestoreInterval)
            lives = min(maxLives, lives + livesToRestore)
            nextLifeIn = lifeRestoreInterval - (elapsedTime.truncatingRemainder(dividingBy: lifeRestoreInterval))
            UserDefaults.standard.set(lives, forKey: livesKey)
            if lives < maxLives {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimer() {
        if nextLifeIn > 0 {
            nextLifeIn -= 1
            if nextLifeIn <= 0 {
                nextLifeIn = 0
                restoreLives()
            }
        }
    }
    
    func formattedTime(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    deinit {
        stopTimer()
    }
}
