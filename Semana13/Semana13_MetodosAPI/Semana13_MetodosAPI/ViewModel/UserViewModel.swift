// Desarrollado por: Diego Nina Malqui

import Foundation
import Combine

class UserViewModel: ObservableObject {

    @Published var users: [User] = []
    @Published var errorMessage: String? = nil

    private let sesion: SesionDeRed
    private let baseURL = "https://jsonplaceholder.typicode.com/users"

    init(sesion: SesionDeRed = URLSession.shared) {
        self.sesion = sesion
    }

    // MARK: - GET

    func fetchUsers() async {
        guard let url = URL(string: baseURL) else { return }

        do {
            let (data, _) = try await sesion.data(from: url)
            let decodedUsers = try JSONDecoder().decode([User].self, from: data)

            await MainActor.run {
                self.users = decodedUsers
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - POST

    func addUser(_ user: User) async {
        guard let url = URL(string: baseURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(user)

        do {
            let (data, _) = try await sesion.data(for: request)
            let createdUser = try JSONDecoder().decode(User.self, from: data)

            await MainActor.run {
                self.users.append(createdUser)
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - PUT

    func updateUser(_ user: User) async {
        guard let url = URL(string: "\(baseURL)/\(user.id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(user)

        do {
            _ = try await sesion.data(for: request)

            await MainActor.run {
                if let index = self.users.firstIndex(where: { $0.id == user.id }) {
                    self.users[index] = user
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - DELETE

    func deleteUser(_ user: User) async {
        guard let url = URL(string: "\(baseURL)/\(user.id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            _ = try await sesion.data(for: request)

            await MainActor.run {
                self.users.removeAll { $0.id == user.id }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
