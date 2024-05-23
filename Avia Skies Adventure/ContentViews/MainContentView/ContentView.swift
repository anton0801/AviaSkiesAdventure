import SwiftUI

struct ContentView: View {
    
    @State var userData = UserData()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    ZStack {
                        Image("btn_bg")
                            .resizable()
                            .frame(width: 130, height: 30)
                        Text("\(userData.credits)")
                            .font(.custom("CarterOne", size: 20))
                            .foregroundColor(.white)
                        Image("coin")
                            .offset(x: -55)
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                NavigationLink(destination: SkiesAdventureGameView()
                    .environmentObject(userData)
                    .navigationBarBackButtonHidden(true)) {
                        ZStack {
                            Image("btn_bg")
                            Text("PLAY")
                                .font(.custom("CarterOne", size: 42))
                                .foregroundColor(.white)
                        }
                    }
                
                NavigationLink(destination: ShopView()
                    .environmentObject(userData)
                    .navigationBarBackButtonHidden(true)) {
                        ZStack {
                            Image("btn_bg")
                            Text("SHOP")
                                .font(.custom("CarterOne", size: 42))
                                .foregroundColor(.white)
                        }
                    }
                
                NavigationLink(destination: SettingsView()
                    .environmentObject(userData)
                    .navigationBarBackButtonHidden(true)) {
                        ZStack {
                            Image("btn_bg")
                            Text("SETTINGS")
                                .font(.custom("CarterOne", size: 42))
                                .foregroundColor(.white)
                        }
                    }
                
                Spacer()
            }
            .background(
                Image("app_content_bg")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    ContentView()
}
