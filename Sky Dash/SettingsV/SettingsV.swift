import SwiftUI

struct SettingsV: View {
    
    @Environment(\.presentationMode) var pm
    @State var musSounds = false {
        didSet {
            saveMusSettings()
        }
    }
    
    @StateObject var settingsSounds = SettingsSounds()
    
    private func saveMusSettings() {
        UserDefaults.standard.set(musSounds, forKey: "mus")
    }
    
    init() {
        musSounds = UserDefaults.standard.bool(forKey: "mus")
    }
    
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
            Spacer()
            
            ZStack {
                Image("mus_settings")
                if musSounds {
                    Button {
                        withAnimation(.linear(duration: 0.4)) {
                            musSounds = false
                        }
                    } label: {
                        Image("on_toggle")
                            .offset(x: 60)
                    }
                } else {
                    Button {
                        withAnimation(.linear(duration: 0.4)) {
                            musSounds = true
                        }
                    } label: {
                        Image("off_toggle")
                            .offset(x: 60)
                    }
                }
            }
            
            ZStack {
                Image("soun_settings")
                if settingsSounds.soundsSound {
                    Button {
                        withAnimation(.linear(duration: 0.4)) {
                            settingsSounds.soundsSound = false
                        }
                    } label: {
                        Image("on_toggle")
                            .offset(x: 60)
                    }
                } else {
                    Button {
                        withAnimation(.linear(duration: 0.4)) {
                            settingsSounds.soundsSound = true
                        }
                    } label: {
                        Image("off_toggle")
                            .offset(x: 60)
                    }
                }
            }
            
            Spacer()
            Text("SETTINGS")
                .font(.custom("Chewy-Regular", size: 62))
                .foregroundColor(.white)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    self.goBack()
                } label: {
                    Image("home_button")
                }
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
    }
    
    private func goBack() {
        pm.wrappedValue.dismiss()
    }
    
}

class SettingsSounds: ObservableObject {
    
    @Published var soundsSound = false {
        didSet {
            saveSoundsSettings()
        }
    }
    
    private func saveSoundsSettings() {
        UserDefaults.standard.set(soundsSound, forKey: "ssound")
    }
    
    init() {
        soundsSound = UserDefaults.standard.bool(forKey: "ssound")
    }
    
    
}

#Preview {
    SettingsV()
}
