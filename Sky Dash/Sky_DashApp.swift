import SwiftUI

@main
struct Sky_DashApp: App {
    
    init() {
        if !UserDefaults.standard.bool(forKey: "is_not_first_launch") {
            UserDefaults.standard.set(3, forKey: "lifes_available")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ChooserGameView()
        }
    }
}
