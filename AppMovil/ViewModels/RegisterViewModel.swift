//
//  RegisterViewModel.swift
//  AppMovil
//
//  Created by DAMII on 16/12/24.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

class RegisterViewModel: ObservableObject {
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    func registerUser(fullName: String, email: String, phoneNumber: String, username: String, password: String, dateOfBirth: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // Crear el usuario en Firebase Auth
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = "Error al registrar: \(error.localizedDescription)"
                completion(false)
                return
            }

            guard let userID = result?.user.uid else {
                self.errorMessage = "Error inesperado. Intenta nuevamente."
                completion(false)
                return
            }
            
            // Guardar datos adicionales en Firestore
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "fullName": fullName,
                "email": email,
                "phoneNumber": phoneNumber,
                "username": username,
                "dateOfBirth": dateOfBirth,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            db.collection("users").document(userID).setData(userData) { error in
                if let error = error {
                    self.errorMessage = "Error al guardar datos: \(error.localizedDescription)"
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
