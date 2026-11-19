// Desarrollado por: Diego Nina Malqui

import Foundation
import Combine

class UserViewModel: ObservableObject {

    @Published var users: [User] = []

    private let baseURL = "https://jsonplaceholder.typicode.com/users"

    // MARK: - GET

    func fetchUsers() {
        guard let url = URL(string: baseURL) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            guard let decodedUsers = try? JSONDecoder().decode([User].self, from: data) else { return }

            DispatchQueue.main.async {
                self.users = decodedUsers
            }
        }.resume()
    }

    // MARK: - POST

    func addUser(_ user: User) {
        guard let url = URL(string: baseURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(user)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            guard let createdUser = try? JSONDecoder().decode(User.self, from: data) else { return }

            DispatchQueue.main.async {
                self.users.append(createdUser)
            }
        }.resume()
    }

    // MARK: - PUT

    func updateUser(_ user: User) {
        guard let url = URL(string: "\(baseURL)/\(user.id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(user)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard data != nil, error == nil else { return }

            DispatchQueue.main.async {
                if let index = self.users.firstIndex(where: { $0.id == user.id }) {
                    self.users[index] = user
                }
            }
        }.resume()
    }

    // MARK: - DELETE

    func deleteUser(_ user: User) {
        guard let url = URL(string: "\(baseURL)/\(user.id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil else { return }

            DispatchQueue.main.async {
                self.users.removeAll { $0.id == user.id }
            }
        }.resume()
    }
}
