//
//  Review.swift
//  Firestore: reviews/{eventId_reviewerId}
//

import Foundation
import FirebaseFirestore

struct Review: Codable, Identifiable {
    @DocumentID var id: String?
    var eventId: String
    var hostId: String
    var reviewerId: String
    var eventRating: Int           // 1 to 5
    var hostRating: Int            // 1 to 5
    var comment: String?
    var createdAt: Date

    static func documentId(eventId: String, reviewerId: String) -> String {
        "\(eventId)_\(reviewerId)"
    }
}
