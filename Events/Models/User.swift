//
//  User.swift
//  Firestore: users/{userId}
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var fullName: String
    var email: String
    var photoURL: String?          // Storage path, e.g. "profilePhotos/{userId}.jpg"
    var bio: String?
    var city: String
    var interestIds: [String]
    var preferences: Preferences
    var activeMode: Mode
    var onboardingComplete: Bool

    // Host fields
    var hostTagline: String?
    var hostThemeIds: [String]
    var isVerified: Bool
    var hostRatingAvg: Double
    var hostRatingCount: Int
    var eventsHostedCount: Int
    var guestsHostedCount: Int

    // Guest fields
    var eventsAttendedCount: Int

    struct Preferences: Codable {
        var maxDistanceMiles: Int
        var minPriceCents: Int
        var maxPriceCents: Int
    }

    enum Mode: String, Codable {
        case guest, host
    }

    /// Show "No rating yet" instead of a number until someone reviews this host
    var hasHostRating: Bool { hostRatingCount > 0 }
}
