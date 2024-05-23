import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var userData: UserData
    
    @Environment(\.presentationMode) var presentation
    
    @State var music = false
    @State var sounds = false
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Image("btn_bg")
                        .resizable()
                        .frame(width: 130, height: 30)
                    Text("\(userData.credits)")
                        .font(.custom("Recoleta-RegularDEMO", size: 20))
                        .foregroundColor(.white)
                    Image("coin")
                        .offset(x: -55)
                }
                Spacer()
            }
            .padding()
            
            Spacer()
            
            ZStack {
                Image("settings_bg")
                VStack {
                    HStack {
                        Text("MUSIC")
                            .font(.custom("CarterOne", size: 28))
                            .foregroundColor(.white)
                        
                        Toggle(isOn: $music) {
                            EmptyView()
                        }
                        .onChange(of: music) { _ in
                            UserDefaults.standard.set(music, forKey: .musicKey)
                        }
                    }
                    .padding([.leading, .trailing])
                    .frame(width: 300)
                    
                    HStack {
                        Text("SOUNDS")
                            .font(.custom("CarterOne", size: 28))
                            .foregroundColor(.white)
                        
                        Toggle(isOn: $sounds) {
                            EmptyView()
                        }
                        .onChange(of: sounds) { _ in
                            UserDefaults.standard.set(sounds, forKey: .soundsKey)
                        }
                    }
                    .padding([.leading, .trailing])
                    .frame(width: 300)
                }
            }
            
            Button {
                presentation.wrappedValue.dismiss()
            } label: {
                ZStack {
                    Image("btn_bg")
                    Text("BACK")
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
        .onAppear {
            music = UserDefaults.standard.bool(forKey: .musicKey)
            sounds = UserDefaults.standard.bool(forKey: .soundsKey)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserData())
}
