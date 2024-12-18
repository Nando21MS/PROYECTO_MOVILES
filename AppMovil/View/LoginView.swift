import SwiftUI

struct LoginView: View {
    @State private var email: String = "" // Correo electrónico
    @State private var password: String = "" // Contraseña
    @State private var showAlert: Bool = false // Alerta de error
    @State private var alertMessage: String = "" // Mensaje de alerta

    @StateObject private var viewModel = LoginViewModel() // Instancia del ViewModel

    var body: some View {
        NavigationStack {
            if viewModel.isAuthenticated {
                HomeView(username: viewModel.username ?? "Usuario") // Pasar el username a HomeView
            } else {
                GeometryReader { geometry in
                    ZStack {
                        // Fondo blanco
                        Color.white
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            Spacer() // Empuja todo hacia el centro de la pantalla

                            VStack(spacing: 20) {
                                // Título: Iniciar sesión
                                Text("Iniciar sesión")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.black) // Título en color negro
                                
                                // Campo de texto: Email
                                TextField("Correo electrónico", text: $email)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                                    .padding(.horizontal)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .keyboardType(.emailAddress)
                                    .padding(.bottom, 10)
                                    .onSubmit {
                                        loginUser() // Ejecuta la función al presionar Enter
                                    }

                                // Campo de texto: Contraseña
                                SecureField("Contraseña", text: $password)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                                    .padding(.horizontal)
                                    .padding(.bottom, 10)
                                    .onSubmit {
                                        loginUser() // Ejecuta la función al presionar Enter
                                    }

                                
                                // Botón para iniciar sesión
                                Button(action: {
                                    loginUser()
                                }) {
                                    Text("Iniciar sesión")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue))
                                        .shadow(radius: 10)
                                        .padding(.horizontal)
                                }
                                
                                // Botón para navegar a la pantalla de registro
                                HStack {
                                    Text("¿No tienes cuenta?")
                                        .foregroundColor(.black) // Texto en negro para mayor contraste
                                    
                                    NavigationLink(destination: RegisterView()) { // Aquí se asegura la navegación
                                        Text("Registrarse")
                                            .fontWeight(.bold)
                                            .foregroundColor(.yellow) // Color amarillo para el botón
                                    }
                                }
                                .padding(.top, 20)
                            }
                            .padding(.horizontal)
                            .frame(width: geometry.size.width * 0.85) // Ajustar el ancho del formulario

                            Spacer() // Empuja el contenido hacia el centro de la pantalla
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    .navigationBarBackButtonHidden(true) // Aquí oculto el botón de "back"

                    // Alerta si las credenciales son incorrectas
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                }
            }
        }
    }
    
    private func loginUser() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Por favor, completa todos los campos."
            showAlert = true
            return
        }

        viewModel.loginUser(email: email, password: password) { success in
            if success {
                // Autenticación exitosa
                viewModel.isAuthenticated = true
            } else {
                // Error al iniciar sesión
                alertMessage = viewModel.errorMessage ?? "Error desconocido"
                showAlert = true
            }
        }
    }
}


#Preview {
    LoginView()
}
