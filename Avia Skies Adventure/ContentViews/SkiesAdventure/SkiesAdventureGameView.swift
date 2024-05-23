import SwiftUI
import SpriteKit

struct SkiesAdventureGameView: View {
    
    @Environment(\.presentationMode) var presentaionMode
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        VStack {
            SpriteView(scene: SkiesAdventureScene())
                .ignoresSafeArea()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("home"))) { _ in
            presentaionMode.wrappedValue.dismiss()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("claim_coins"))) { notification in
            if let userInfo = notification.userInfo,
               let credits = userInfo["credits"] as? Int {
                userData.credits += credits
            }
        }
    }
}

#Preview {
    SkiesAdventureGameView()
        .environmentObject(UserData())
}
