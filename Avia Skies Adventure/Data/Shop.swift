import Foundation

struct ShopModelItem: Identifiable {
    let id: String
    let plane: String
    let price: Int
    let isBuyed: Bool
}

let allPlanes = [
    ShopModelItem(id: "plane_base", plane: "plane_base", price: 0, isBuyed: true),
    ShopModelItem(id: "plane_buy_1", plane: "plane_buy_2", price: 20000, isBuyed: false),
    ShopModelItem(id: "plane_buy_2", plane: "plane_buy_3", price: 50000, isBuyed: false)
]

class Shop: ObservableObject {
    
    @Published var planesInStock = [
        ShopModelItem(id: "plane_base", plane: "plane_base", price: 0, isBuyed: true)
    ]
    
    init() {
        firstSetUp()
        initPlanesInStock()
    }
    
    private func firstSetUp() {
        if !UserDefaults.standard.bool(forKey: .isStoreSetUppedKey) {
            UserDefaults.standard.set(true, forKey: "plane_base_buy")
            UserDefaults.standard.set(true, forKey: .isStoreSetUppedKey)
        }
    }
    
    private func initPlanesInStock() {
        planesInStock = []
        for plane in allPlanes {
            planesInStock.append(ShopModelItem(id: plane.id, plane: plane.plane, price: plane.price, isBuyed: UserDefaults.standard.bool(forKey: "\(plane.id)_buy")))
        }
    }
    
    func buyPlane(availablePointsUser: Int, shopModelItem: ShopModelItem) -> Bool {
        if availablePointsUser >= shopModelItem.price {
            UserDefaults.standard.set(true, forKey: "\(shopModelItem.id)_buy")
            initPlanesInStock()
            return true
        }
        return false
    }
    
}
