//
//  SavedEvent.swift
//  Firestore: users/{userId}/savedEvents/{eventId}
//

import Foundation
import FirebaseFirestore

struct SavedEvent: Codable, Identifiable {
    @DocumentID var id: String?    // the eventId
    var savedAt: Date
}
