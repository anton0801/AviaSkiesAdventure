import Foundation

class UserData: ObservableObject {
    
    @Published var plane: String = UserDefaults.standard.string(forKey: .selectedPlaneKey) ?? "plane_base"
    @Published var credits: Int = UserDefaults.standard.integer(forKey: .pointsKey)
    
    func setSelectedPlane(plane: String) {
        self.plane = plane
        UserDefaults.standard.set(plane, forKey: .selectedPlaneKey)
    }
    
    func setCredits(credits: Int) {
        self.credits = credits
        UserDefaults.standard.set(credits, forKey: .pointsKey)
    }
    
}
