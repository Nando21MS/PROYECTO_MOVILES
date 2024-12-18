//
//  RegisterView.swift
//  AppMovil
//
//  Created by DAMII on 16/12/24.
//

import SwiftUI
struct RegisterView: View {
    @State private var username = ""
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var selectedGender: String? = nil
    @State private var month = ""
    @State private var day = ""
    @State private var year = ""
    @State private var agreeToTerms = false
    @StateObject private var viewModel = RegisterViewModel()

    // Alert and navigation
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo blanco
                Color.white
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Título
                    Text("Registrarse")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black)

                    // Campo de texto: Nombre completo
                    RoundedTextField(placeholder: "Nombre completo", text: $fullName)

                    // Campo de texto: Correo electrónico
                    RoundedTextField(placeholder: "E-mail", text: $email, keyboardType: .emailAddress)
                        .autocapitalization(.none)

                    // Campo de texto: Celular
                    RoundedTextField(placeholder: "Celular", text: $phoneNumber, keyboardType: .numberPad)

                    // Campo de texto: Nombre de usuario
                    RoundedTextField(placeholder: "Nombre Usuario", text: $username)
                        .autocapitalization(.none)

                    // Campo de texto: Contraseña con botón de visibilidad
                    ZStack {
                        RoundedTextField(
                            placeholder: "Contraseña",
                            text: $password,
                            isSecure: !isPasswordVisible
                        )
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .onSubmit {
                        registerUser()
                    }

                    // Fecha de nacimiento
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Fecha de Nacimiento")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            RoundedTextField(placeholder: "DD", text: $day, keyboardType: .numberPad, width: 65)
                            RoundedTextField(placeholder: "MM", text: $month, keyboardType: .numberPad, width: 65)
                            RoundedTextField(placeholder: "YYYY", text: $year, keyboardType: .numberPad, width: 80)
                        }
                    }

                    // Términos y condiciones
                    Toggle(isOn: $agreeToTerms) {
                        Text("Acepto los términos y condiciones")
                            .foregroundColor(.black)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .padding(.top, 20)

                    // Botón para crear cuenta
                    Button(action: {
                        registerUser()
                    }) {
                        Text("Crear Cuenta")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.green))
                            .shadow(radius: 10)
                            .padding(.horizontal)
                    }

                    // Redirigir al Login
                    NavigationLink(destination: LoginView(isLoggedOut: .constant(true))) {
                        HStack {
                            Text("¿Ya tienes cuenta?")
                                .foregroundColor(.black)

                            Text("Iniciar sesión")
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.top, 10)

                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: 350)
            }
            
            // Alerta
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Registro"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // Función para registrar usuario
    private func registerUser() {
        if validateInputs() {
            let dateOfBirth = "\(month)/\(day)/\(year)"
            viewModel.registerUser(
                fullName: fullName,
                email: email,
                phoneNumber: phoneNumber,
                username: username,
                password: password,
                dateOfBirth: dateOfBirth
            ) { success in
                if success {
                    alertMessage = "Usuario registrado exitosamente"
                    showAlert = true
                } else {
                    alertMessage = viewModel.errorMessage ?? "Error desconocido"
                    showAlert = true
                }
            }
        }
    }

    // Validación de campos
    private func validateInputs() -> Bool {
        // Validar que los campos no estén vacíos
        guard !fullName.isEmpty, !email.isEmpty, !phoneNumber.isEmpty, !username.isEmpty, !password.isEmpty else {
            alertMessage = "Por favor, completa todos los campos."
            showAlert = true
            return false
        }

        // Validar términos y condiciones
        guard agreeToTerms else {
            alertMessage = "Debes aceptar los términos y condiciones."
            showAlert = true
            return false
        }

        // Validar día
        guard let dayInt = Int(day), dayInt >= 1, dayInt <= 31, day.count == 2 else {
            alertMessage = "El día debe ser un número entre 01 y 31."
            showAlert = true
            return false
        }

        // Validar mes
        guard let monthInt = Int(month), monthInt >= 1, monthInt <= 12, month.count == 2 else {
            alertMessage = "El mes debe ser un número entre 01 y 12."
            showAlert = true
            return false
        }

        // Validar año
        guard let yearInt = Int(year), year.count == 4 else {
            alertMessage = "El año debe ser un número de 4 dígitos."
            showAlert = true
            return false
        }

        // Validar que el usuario tenga al menos 14 años
        let calendar = Calendar.current
        let currentDate = Date()
        let birthDateComponents = DateComponents(year: yearInt, month: monthInt, day: dayInt)
        if let birthDate = calendar.date(from: birthDateComponents) {
            let age = calendar.dateComponents([.year], from: birthDate, to: currentDate).year ?? 0
            if age < 14 {
                alertMessage = "Debes tener al menos 14 años para registrarte."
                showAlert = true
                return false
            }
        } else {
            alertMessage = "Fecha de nacimiento inválida."
            showAlert = true
            return false
        }

        // Si todas las validaciones pasan
        return true
    }
}

// Campo de texto reutilizable con diseño similar al LoginView
struct RoundedTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var width: CGFloat? = nil

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding()
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none) // Evitar la autocapitalización
                    .padding()
            }
        }
        .frame(width: width)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .foregroundColor(.black)
    }
}


#Preview {
    RegisterView()
}
