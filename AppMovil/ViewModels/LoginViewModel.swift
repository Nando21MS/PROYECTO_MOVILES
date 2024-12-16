//
//  LoginViewModel.swift
//  ToDoSwiftUI
//
//  Created by DAMII on 14/12/24.
//
import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var isAuthenticated = false
       @Published var username: String? = nil // Nombre de usuario actual
       @Published var errorMessage: String? = nil

       func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
           Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
               if let error = error {
                   self?.errorMessage = "Error: \(error.localizedDescription)"
                   completion(false)
                   return
               }

               // Extraer el nombre de usuario desde Firebase si es necesario
               if let user = result?.user {
                   self?.username = user.email // Aquí podrías usar un campo más descriptivo si está disponible
                   self?.isAuthenticated = true
                   completion(true)
               } else {
                   self?.errorMessage = "Usuario no encontrado"
                   completion(false)
               }
           }
       }
}
