//
//  RSVP.swift
//  Firestore: events/{eventId}/rsvps/{userId}
//

import Foundation
import FirebaseFirestore

struct RSVP: Codable, Identifiable {
    @DocumentID var id: String?    // the userId
    var userId: String
    var eventId: String
    var userName: String
    var userPhotoURL: String?
    var userInterestIds: [String]
    var status: Status
    var qrToken: String
    var paymentId: String
    var depositStatus: DepositStatus
    var amountPaidCents: Int
    var rsvpAt: Date
    var cancelledAt: Date?
    var checkedInAt: Date?

    enum Status: String, Codable {
        case attending, cancelled, checkedIn, noShow
    }

    enum DepositStatus: String, Codable {
        case held, refunded, forfeited
    }
}
