//
//  PerfilViewModel.swift
//  AppMovil
//
//  Created by DAMII on 17/12/24.
//
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import FirebaseAuth


class PerfilViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var dateOfBirth: String = ""
    @Published var createdAt: String = ""
    @Published var profileImage: Image?

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var userId: String?

    init() {
        // Obtener el UID del usuario autenticado
        if let uid = Auth.auth().currentUser?.uid {
            self.userId = uid
            fetchUserProfile()
        } else {
            print("No hay un usuario autenticado.")
        }
    }

    func fetchUserProfile() {
        guard let userId = userId else { return }

        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                return
            }

            if let data = snapshot?.data() {
                self.fullName = data["fullName"] as? String ?? ""
                self.username = data["username"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
                self.phoneNumber = data["phoneNumber"] as? String ?? ""
                self.dateOfBirth = data["dateOfBirth"] as? String ?? ""

                if let timestamp = data["createdAt"] as? Timestamp {
                    let date = timestamp.dateValue()
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .short
                    self.createdAt = formatter.string(from: date)
                } else {
                    self.createdAt = "No disponible"
                }

                if let profileImageURL = data["profileImageURL"] as? String {
                    self.loadProfileImage(from: profileImageURL)
                }
            }
        }
    }

    // Cargar la imagen de perfil
    func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = Image(uiImage: uiImage)
                }
            }
        }.resume()
    }

    // Función para guardar los datos editados
    func saveProfileData() {
        guard let userId = userId else { return }

        db.collection("users").document(userId).updateData([
            "fullName": fullName,
            "username": username,
            "email": email,
            "phoneNumber": phoneNumber,
            "dateOfBirth": dateOfBirth,
            "profileImage": profileImage
        ]) { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                print("Profile updated successfully.")
            }
        }
    }
}
