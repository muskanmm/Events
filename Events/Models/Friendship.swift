//
//  Friendship.swift
//  Firestore: friendships/{userA_userB}
//

import Foundation
import FirebaseFirestore

struct Friendship: Codable, Identifiable {
    @DocumentID var id: String?
    var userIds: [String]
    var requesterId: String
    var status: Status
    var createdAt: Date
    var acceptedAt: Date?

    enum Status: String, Codable {
        case pending, accepted
    }

    /// Doc ID for a pair of users, same no matter who sends the request
    static func documentId(_ a: String, _ b: String) -> String {
        [a, b].sorted().joined(separator: "_")
    }
}
