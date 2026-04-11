import SwiftUI

struct MenuBarAuthView: View {
    @EnvironmentObject var service: MacFirebaseService
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "checklist")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text("Notelayer")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            VStack(spacing: 12) {
                Text("Sign in to your account")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .email)
                    .textContentType(.emailAddress)
                    .onSubmit { focusedField = .password }

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .password)
                    .onSubmit { signIn() }

                if let error = service.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: signIn) {
                    if service.isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty || service.isLoading)
                .keyboardShortcut(.return, modifiers: [])
            }
            .padding(16)
        }
        .onAppear { focusedField = .email }
    }

    private func signIn() {
        Task { await service.signIn(email: email, password: password) }
    }
}
