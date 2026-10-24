//
//  Event.swift
//  Firestore: events/{eventId}
//

import Foundation
import FirebaseFirestore

struct Event: Codable, Identifiable {
    @DocumentID var id: String?
    var hostId: String
    var hostName: String
    var hostPhotoURL: String?
    var title: String
    var categoryId: String
    var description: String
    var coverPhotoURL: String      // Storage path, e.g. "eventCovers/{eventId}.jpg"
    var startAt: Date
    var endAt: Date
    var rsvpDeadline: Date
    var locationName: String
    var address: String
    var neighborhood: String
    var coordinates: GeoPoint
    var capacity: Int
    var priceCents: Int            // event cost, separate from deposit
    var depositCents: Int
    var cancellationHours: Int
    var status: Status
    var attendingCount: Int
    var checkedInCount: Int
    var createdAt: Date
    var updatedAt: Date

    enum Status: String, Codable {
        case live, cancelled, completed
    }

    // Computed values used by cards and the host dashboard
    var spotsLeft: Int { max(capacity - attendingCount, 0) }
    var percentFull: Double { capacity == 0 ? 0 : Double(attendingCount) / Double(capacity) }
    var isNearlyFull: Bool { percentFull >= 0.8 }
    var isPast: Bool { endAt < Date() }
    var rsvpOpen: Bool { status == .live && Date() < rsvpDeadline && spotsLeft > 0 }
    var priceText: String { priceCents == 0 ? "Free" : Money.format(priceCents) }
    var depositText: String { Money.format(depositCents) }
}
