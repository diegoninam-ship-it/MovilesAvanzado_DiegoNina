// Desarrollado por: Diego Nina Malqui

import Foundation
import Combine

class UserViewModel: ObservableObject {

    @Published var users: [User] = []

    private let usersURL = URL(string: "https://jsonplaceholder.typicode.com/users")!

    // MARK: - Consumo de API (GET)

    func fetchUsers() {
        URLSession.shared.dataTask(with: usersURL) { data, _, error in
            guard let data = data, error == nil else { return }
            guard let decodedUsers = try? JSONDecoder().decode([User].self, from: data) else { return }

            DispatchQueue.main.async {
                self.users = decodedUsers
            }
        }.resume()
    }
}
