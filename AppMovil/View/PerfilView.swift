import SwiftUI
import UIKit
import Firebase
import FirebaseAuth

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
// Función para obtener el avatar desde la API
func fetchAvatarImage(for initials: String, completion: @escaping (UIImage?) -> Void) {
    let urlString = "https://ui-avatars.com/api/?name=\(initials)&background=random&color=fff"
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, _, _ in
        if let data = data, let image = UIImage(data: data) {
            DispatchQueue.main.async {
                completion(image)
            }
        } else {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }.resume()
}

struct PerfilView: View {
    @StateObject private var viewModel = PerfilViewModel()
    @State private var showingImagePicker = false
    @State private var newImage: UIImage?  // Imagen seleccionada
    @State private var isEditing = false  // Estado para habilitar/deshabilitar edición
    @State private var avatarImage: UIImage?  // Imagen de avatar generada
    @Binding var isLoggedOut: Bool  // Binding para cambiar el estado de sesión

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                ZStack {
                    Button(action: { showingImagePicker.toggle() }) {
                        ZStack {
                            if let newImage = newImage {
                                Image(uiImage: newImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                            }
                            else if let avatarImage = avatarImage {
                                Image(uiImage: avatarImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 140, height: 140)
                                    .overlay(Image(systemName: "person.fill").font(.system(size: 60)).foregroundColor(.white))
                                    .shadow(radius: 10)
                            }
                        }
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(image: $newImage)
                    }

                    Button(action: {
                        if isEditing {
                            fetchAvatarImage(for: viewModel.username) { image in
                                avatarImage = image
                            }
                        }
                        isEditing.toggle()
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(isEditing ? .blue : .gray)
                            .padding(5)
                            .background(Circle().fill(Color.white.opacity(0.7)))
                            .shadow(radius: 5)
                    }
                    .position(x: 110, y: 25)
                }

                if isEditing {
                    Button("Guardar") {
                        viewModel.saveProfileData()
                        isEditing.toggle()
                    }
                    .botonEstilo(color: .blue)
                }

                campoTexto(titulo: "Nombre Completo", valor: $viewModel.fullName, editable: isEditing)
                campoTexto(titulo: "Usuario", valor: $viewModel.username, editable: isEditing)
                campoTexto(titulo: "Correo Electrónico", valor: $viewModel.email, editable: isEditing)
                campoTexto(titulo: "Número de Teléfono", valor: $viewModel.phoneNumber, editable: isEditing)
                campoTexto(titulo: "Fecha de Nacimiento", valor: $viewModel.dateOfBirth, editable: isEditing)
                campoTexto(titulo: "Creado el", valor: Binding.constant(viewModel.createdAt), editable: false)
                
                Button("Cerrar sesión") {
                    do {
                        try Auth.auth().signOut()
                        isLoggedOut = true
                    } catch {
                        print("Error al cerrar sesión: \(error.localizedDescription)")
                    }
                }
                .botonEstilo(color: .red)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mi Perfil")
        .navigationBarHidden(true)
    }
}

func campoTexto(titulo: String, valor: Binding<String>, editable: Bool) -> some View {
    HStack {
        Text("\(titulo):")
            .font(.headline)
            .foregroundColor(.primary)
        Spacer()
        if editable {
            TextField(titulo, text: valor)
                .font(.body)
                .foregroundColor(.secondary)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        } else {
            Text(valor.wrappedValue)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    .padding(.horizontal)
}

extension View {
    func botonEstilo(color: Color) -> some View {
        self.fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12).fill(color))
            .shadow(radius: 10)
            .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        PerfilView(isLoggedOut: .constant(true)) // Usar un Binding constante
    }
}
