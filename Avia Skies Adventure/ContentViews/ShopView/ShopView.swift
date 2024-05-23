import SwiftUI

struct ShopView: View {
    
    @EnvironmentObject var userData: UserData
    
    @Environment(\.presentationMode) var presentation
    
    @State var shop = Shop()
    
    @State var buyStatus = false
    @State var buyPlaneId: String? = nil
    
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
            
            ForEach(shop.planesInStock, id: \.id) { plane in
                ZStack {
                    Image("settings_bg")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width - 100, height: 190)
                    VStack {
                        Image(plane.plane)
                            .resizable()
                            .frame(width: 110, height: 110)
                        if userData.plane == plane.plane {
                            Text("SELECTED")
                               .font(.custom("CarterOne", size: 24))
                               .foregroundColor(.white)
                        } else {
                            if !plane.isBuyed {
                                HStack {
                                    ZStack {
                                        Image("btn_bg")
                                            .resizable()
                                            .frame(width: 130, height: 30)
                                        Text("\(plane.price)")
                                            .font(.custom("CarterOne", size: 16))
                                            .foregroundColor(.white)
                                            .offset(x: 10)
                                        Image("coin")
                                            .offset(x: -55)
                                    }
                                    Spacer()
                                    Button {
                                        withAnimation {
                                            buyStatus = !shop.buyPlane(availablePointsUser: userData.credits, shopModelItem: plane)
                                        }
                                        buyPlaneId = plane.id
                                        if !buyStatus {
                                            userData.setCredits(credits: userData.credits - plane.price)
                                        }
                                    } label: {
                                        ZStack {
                                            Image("btn_bg")
                                                .resizable()
                                                .frame(width: 80, height: 30)
                                            Text("BUY")
                                                .font(.custom("CarterOne", size: 24))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .padding()
                                .frame(width: UIScreen.main.bounds.width - 100, height: 40)
                                
                                if buyStatus && buyPlaneId == plane.id {
                                    Text("Error buy this plane! Not enought points!")
                                        .font(.custom("CarterOne", size: 14))
                                        .foregroundColor(.red)
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                buyStatus = false
                                                buyPlaneId = nil
                                            }
                                        }
                                }
                            } else {
                                Button {
                                    userData.plane = plane.plane
                                } label: {
                                    ZStack {
                                        Image("btn_bg")
                                            .resizable()
                                            .frame(width: 80, height: 30)
                                        Text("SELECT")
                                            .font(.custom("CarterOne", size: 24))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
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
        }
        .background(
            Image("app_content_bg")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    ShopView()
        .environmentObject(UserData())
}
