//
//  ImageUploadDemo.swift
//  Demonstrates the full image round trip:
//    1. pick a photo
//    2. upload it to Firebase Storage
//    3. save its Storage path on the Firestore document
//    4. read the path back from Firestore and display the image
//

import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

// MARK: - Storage helper (reuse this in the real app)

enum ImageStore {

    /// Uploads JPEG data to the given Storage path, e.g. "profilePhotos/user_luciana.jpg"
    static func upload(_ data: Data, toPath path: String) async throws {
        let ref = Storage.storage().reference(withPath: path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await ref.putDataAsync(data, metadata: metadata)
    }

    /// Turns a Storage path into a URL that AsyncImage can load
    static func downloadURL(forPath path: String) async throws -> URL {
        try await Storage.storage().reference(withPath: path).downloadURL()
    }
}

// MARK: - Which document the image belongs to

enum UploadTarget: String, CaseIterable, Identifiable {
    case profilePhoto = "Profile photo"
    case eventCover = "Event cover"

    var id: String { rawValue }

    var collection: String { self == .profilePhoto ? "users" : "events" }
    var documentId: String { self == .profilePhoto ? "user_luciana" : "event_rooftop_mixer" }
    var field: String { self == .profilePhoto ? "photoURL" : "coverPhotoURL" }
    var storagePath: String {
        self == .profilePhoto ? "profilePhotos/\(documentId).jpg" : "eventCovers/\(documentId).jpg"
    }
}

// MARK: - Demo view

struct ImageUploadDemoView: View {
    @State private var target: UploadTarget = .profilePhoto
    @State private var pickedItem: PhotosPickerItem?
    @State private var imageURL: URL?
    @State private var status = "Pick a photo to upload"
    @State private var isWorking = false

    var body: some View {
        VStack(spacing: 20) {
            Picker("Upload as", selection: $target) {
                ForEach(UploadTarget.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            Group {
                if let imageURL {
                    AsyncImage(url: imageURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 220, height: 220)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            PhotosPicker("Choose photo", selection: $pickedItem, matching: .images)
                .buttonStyle(.borderedProminent)
                .disabled(isWorking)

            Button("Load current image from Firestore") {
                Task { await loadFromFirestore() }
            }
            .disabled(isWorking)

            Text(status)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .onChange(of: pickedItem) { _, newItem in
            guard let newItem else { return }
            Task { await uploadAndSave(newItem) }
        }
    }

    // Steps 1 to 3: pick, upload to Storage, save path on the Firestore doc
    private func uploadAndSave(_ item: PhotosPickerItem) async {
        isWorking = true
        defer { isWorking = false }
        do {
            status = "Preparing image..."
            guard let raw = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: raw),
                  let jpeg = uiImage.jpegData(compressionQuality: 0.7) else {
                status = "Couldn't read that image"
                return
            }

            status = "Uploading to Storage..."
            try await ImageStore.upload(jpeg, toPath: target.storagePath)

            status = "Saving path to Firestore..."
            try await Firestore.firestore()
                .collection(target.collection)
                .document(target.documentId)
                .updateData([target.field: target.storagePath])

            await loadFromFirestore()
        } catch {
            status = "Failed: \(error.localizedDescription)"
        }
    }

    // Step 4: read the path back from Firestore and display the image
    private func loadFromFirestore() async {
        isWorking = true
        defer { isWorking = false }
        do {
            let snapshot = try await Firestore.firestore()
                .collection(target.collection)
                .document(target.documentId)
                .getDocument()

            guard let path = snapshot.get(target.field) as? String else {
                status = "No image path saved on \(target.collection)/\(target.documentId)"
                return
            }
            imageURL = try await ImageStore.downloadURL(forPath: path)
            status = "Loaded \(path) via \(target.collection)/\(target.documentId).\(target.field)"
        } catch {
            status = "Failed: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ImageUploadDemoView()
}
