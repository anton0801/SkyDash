import SwiftUI

struct PlaneSkinsGameView: View {
    
    @Environment(\.presentationMode) var pm
    
    @State var starsCount: Int = 0 {
        didSet {
            UserDefaults.standard.set(starsCount, forKey: "stars_count")
        }
    }
    @State var selectedPlane: String = UserDefaults.standard.string(forKey: "plane_sel") ?? "base_plane" {
        didSet {
            UserDefaults.standard.set(selectedPlane, forKey: "plane_sel")
        }
    }
    
    init() {
        starsCount = UserDefaults.standard.integer(forKey: "stars_count")
        if selectedPlane.isEmpty {
            selectedPlane = "base_plane"
        }
    }
    
    @StateObject var skinsManager = PlanesSkinsManager()
    
    @State var errorPlaneBuy = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Button {
                    self.goBack()
                } label: {
                    Image("home_button")
                }
                .offset(x: -(UIScreen.main.bounds.width / 2 - 50))
            }
            .frame(width: UIScreen.main.bounds.width)
            ZStack {
                Image("stars_balance")
                Text("\(starsCount)")
                    .font(.custom("Chewy-Regular", size: 32))
                    .foregroundColor(.white)
                    .offset(x: 15)
            }
            Spacer()
            
            HStack {
                ForEach(skinsManager.takeFirstNAvailableSkins(2)) { skin in
                    if selectedPlane == skin.planeSrc {
                        PlaneViewSelected(planeSkin: skin)
                    } else {
                        if skinsManager.isPlanePurchased(skin.planeSrc) {
                            PlaneViewBought(planeSkin: skin, select: { 
                                selectedPlane = skin.planeSrc
                            })
                        } else {
                            PlaneView(planeSkin: skin) {
                                errorPlaneBuy = !skinsManager.purchasePlane(userBalance: starsCount, skin)
                            }.padding(.top)
                        }
                    }
                }
            }
            
            VStack {
                ForEach(skinsManager.takeLastNAvailableSkins(2)) { skin in
                    if selectedPlane == skin.planeSrc {
                        PlaneViewSelected(planeSkin: skin)
                    } else {
                        if skinsManager.isPlanePurchased(skin.planeSrc) {
                            PlaneViewBought(planeSkin: skin, select: {
                                selectedPlane = skin.planeSrc
                            })
                        } else {
                            PlaneView(planeSkin: skin) {
                                errorPlaneBuy = !skinsManager.purchasePlane(userBalance: starsCount, skin)
                            }.padding(.top)
                        }
                    }
                }
            }
            
            Spacer()
            
            Text("SHOP")
                .font(.custom("Chewy-Regular", size: 62))
                .foregroundColor(.white)
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
        .alert(isPresented: $errorPlaneBuy, content: {
            Alert(title: Text("Alert!"),
            message: Text("You don't have enought stars to buy this plane!"),
                  dismissButton: .default(Text("Ok!")))
        })
    }
    
    private func goBack() {
        pm.wrappedValue.dismiss()
    }
    
}

struct PlaneView: View {
    
    var planeSkin: PlaneSkin
    var buy: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                buy()
            } label: {
                VStack(spacing: 0) {
                    Image(planeSkin.planeSrc)
                    HStack {
                        Text("\(planeSkin.price)")
                            .font(.custom("Chewy-Regular", size: 32))
                            .foregroundColor(.white)
                        Image("star")
                    }
                }
            }
        }
        .background(
            Image("plane_available_bg")
        )
        .padding(.horizontal, 24)
    }
}

struct PlaneViewBought: View {
    
    var planeSkin: PlaneSkin
    var select: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Image(planeSkin.planeSrc)
            HStack {
                Text("\(planeSkin.price)")
                    .font(.custom("Chewy-Regular", size: 32))
                    .foregroundColor(.white)
                Button {
                    select()
                } label: {
                    Text("SELECT")
                        .font(.custom("Chewy-Regular", size: 32))
                        .foregroundColor(.white)
                }
            }
        }
        .background(
            Image("plane_bought_bg")
        )
        .padding(.horizontal, 24)
    }
}


struct PlaneViewSelected: View {
    
    var planeSkin: PlaneSkin
    
    var body: some View {
        VStack(spacing: 0) {
            Image(planeSkin.planeSrc)
            Text("SELECTED")
                .font(.custom("Chewy-Regular", size: 32))
                .foregroundColor(.white)
        }
        .background(
            Image("plane_bought_bg")
        )
        .padding(.horizontal, 24)
    }
}

#Preview {
    PlaneSkinsGameView()
}

struct PlaneSkin: Identifiable {
    var id = UUID()
    let planeSrc: String
    let price: Int
}
                        
class PlanesSkinsManager: ObservableObject {
    static let shared = PlanesSkinsManager()
    
    private var defaults = UserDefaults.standard
    
    @Published private(set) var availableSkins: [PlaneSkin] = []
    
    init() {
        loadSkins()
        if isPlanePurchased(availableSkins[0].planeSrc) {
            let _ = purchasePlane(userBalance: 1, availableSkins[0])
        }
    }
    
    func purchasePlane(userBalance: Int, _ plane: PlaneSkin) -> Bool {
        if userBalance >= plane.price {
            UserDefaults.standard.set(true, forKey: "\(plane.planeSrc)_bou")
            loadSkins()
            return true
        }
        return false
    }
    
    private func loadSkins() {
        availableSkins = [
            PlaneSkin(planeSrc: "base_plane", price: 0),
            PlaneSkin(planeSrc: "plane_sky", price: 50),
            PlaneSkin(planeSrc: "plane_swkywalker", price: 100),
            PlaneSkin(planeSrc: "plane_weider", price: 200)
        ]
    }
    
}

extension PlanesSkinsManager {
    func isPlanePurchased(_ planeSrc: String) -> Bool {
        return defaults.bool(forKey: "\(planeSrc)_bou")
    }
    
    func takeFirstNAvailableSkins(_ n: Int) -> [PlaneSkin] {
          return Array(availableSkins.prefix(n))
      }
    
    func takeLastNAvailableSkins(_ n: Int) -> [PlaneSkin] {
          return Array(availableSkins.suffix(n))
      }
}
