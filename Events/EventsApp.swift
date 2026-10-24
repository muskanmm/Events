//
//  EventsApp.swift
//  Events
//
//  Created by Muskan Mankikar on 10/23/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct EventsApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ImageUploadDemoView()
            .task {
                let doc = try? await Firestore.firestore()
                    .collection("events").document("event_rooftop_mixer").getDocument()
                let event = try? doc?.data(as: Event.self)
                print(event?.title ?? "decode failed", event?.percentFull ?? 0)
            }
//            ContentView()
//                .task {
//                    do {
//                        try await SeedData.run()
//                    } catch {
//                        print("Seed failed: \(error)")
//                    }
//                }
        }
    }
}
