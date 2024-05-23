import SwiftUI

struct SplashLoadingContentView: View {
    
    let loadingTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var gameLoaded = false
    @State var loadingProgress = 0
    @State var loadingLineWidth: CGFloat = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                HStack(spacing: 2) {
                    Text("\(loadingProgress)")
                        .font(.custom("Recoleta-RegularDEMO", size: 24))
                        .foregroundColor(.white)
                    Text("%")
                        .foregroundColor(.white)
                        .fontWeight(.black)
                }
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                        .fill(.black)
                        .frame(width: 350, height: 20)
                    
                    RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                        .fill(.white)
                        .frame(width: loadingLineWidth, height: 18)
                }
                
                Spacer().frame(height: 60)
                
                NavigationLink(destination: ContentView()
                    .navigationBarBackButtonHidden(true), isActive: $gameLoaded) {
                        EmptyView()
                    }
            }
            .background(
                Image("app_content_bg")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea()
            )
            .onReceive(loadingTimer) { time in
                loadingProgress += 10
                withAnimation(.linear(duration: 0.5)) {
                    loadingLineWidth = 350 * (Double(loadingProgress) / 100.0)
                }
                if loadingProgress >= 100 {
                    withAnimation {
                        gameLoaded = true
                    }
                }
             }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    SplashLoadingContentView()
}
