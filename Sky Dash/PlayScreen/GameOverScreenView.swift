import SwiftUI

struct GameOverScreenView: View {
    
    @Environment(\.presentationMode) var pm
    var score: Int
    var restartAction: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Image("game_over")
                
                Spacer()
                
                Text("Score:\n\(score)")
                    .font(.custom("Chewy-Regular", size: 52))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
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
                .offset(y: -60)
                HStack {
                    Button {
                        pm.wrappedValue.dismiss()
                    } label: {
                        Image("home_button")
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    Button {
                        restartAction()
                    } label: {
                        Image("restart")
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    NavigationLink(destination: SettingsV()
                        .navigationBarBackButtonHidden(true)) {
                            Image("settings")
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                }
                
                Spacer()
                
                Text("+5")
                    .font(.custom("Chewy-Regular", size: 52))
                    .foregroundColor(.white)
                
                ZStack {
                    Image("stars_balance")
                    Text("\(UserDefaults.standard.integer(forKey: "stars_count"))")
                        .font(.custom("Chewy-Regular", size: 32))
                        .foregroundColor(.white)
                        .offset(x: 15)
                }
            }
            .background(BackgroundImage()
                .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct BackgroundImage: View {
    var body: some View {
        ZStack {
            Image("game_bg")
                .resizable()
                .frame(minWidth: UIScreen.main.bounds.width,
                       minHeight: UIScreen.main.bounds.height)
            Color.black.opacity(0.6)
        }
    }
}

#Preview {
    GameOverScreenView(score: 2, restartAction: { })
}
