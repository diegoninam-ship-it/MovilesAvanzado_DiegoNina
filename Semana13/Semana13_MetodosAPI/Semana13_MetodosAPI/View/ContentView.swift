// Desarrollado por: Diego Nina Malqui

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = UserViewModel()

    var body: some View {
        List(viewModel.users) { user in
            Text(user.name)
        }
        .onAppear {
            viewModel.fetchUsers()
        }
    }
}

#Preview {
    ContentView()
}
