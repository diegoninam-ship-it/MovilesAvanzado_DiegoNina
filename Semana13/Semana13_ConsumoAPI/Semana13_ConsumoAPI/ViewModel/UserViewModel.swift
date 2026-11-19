// Desarrollado por: Diego Nina Malqui

import Foundation
import Combine

class UserViewModel: ObservableObject {

    @Published var users: [User] = []
    @Published var searchText: String = ""

    private let usersURL = URL(string: "https://jsonplaceholder.typicode.com/users")!

    // MARK: - Filtro de busqueda

    var filteredUsers: [User] {
        guard !searchText.isEmpty else { return users }
        return users.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.username.localizedCaseInsensitiveContains(searchText)
        }
    }

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
