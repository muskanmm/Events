//
//  SeedData.swift
//  Creates every Firestore collection by writing sample documents.
//  Uses fixed document IDs, so running it again overwrites instead of duplicating.
//
//  Call once, e.g. from a debug button or .task in your root view:
//      Task { try? await SeedData.run() }
//  Then remove the call.
//

import Foundation
import FirebaseFirestore

enum SeedData {

    static let db = Firestore.firestore()

    // Helper: build a Timestamp from a date string in Chicago time
    static func ts(_ string: String) -> Timestamp {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        f.timeZone = TimeZone(identifier: "America/Chicago")
        return Timestamp(date: f.date(from: string)!)
    }

    static func run() async throws {
        let batch = db.batch()

        // MARK: interests (top level + subcategories)
        let interests: [(id: String, name: String, parent: String?, order: Int)] = [
            ("music", "Music", nil, 0),
            ("sports", "Sports", nil, 1),
            ("education", "Education", nil, 2),
            ("tech", "Tech", nil, 3),
            ("art", "Art", nil, 4),
            ("health", "Health", nil, 5),
            ("travel", "Travel", nil, 6),
            ("food", "Food", nil, 7),
            ("culture", "Culture", nil, 8),
            ("design", "Design", nil, 9),
            ("social", "Social", nil, 10),
            ("cooking", "Cooking", "food", 0),
            ("nutrition", "Nutrition", "food", 1),
            ("pottery", "Pottery", "art", 0),
        ]
        for i in interests {
            var data: [String: Any] = ["name": i.name, "sortOrder": i.order]
            data["parentId"] = i.parent ?? NSNull()
            batch.setData(data, forDocument: db.collection("interests").document(i.id))
        }

        // MARK: users
        // In the real app, the document ID is the Firebase Auth uid.
        let wunwan = db.collection("users").document("user_wunwan")
        batch.setData([
            "fullName": "Wunwan Boonsitanara",
            "email": "wunwan@example.com",
            "photoURL": "profilePhotos/user_wunwan.jpg",
            "bio": "I create welcoming, low-pressure events that make it easier to meet people.",
            "city": "Chicago",
            "interestIds": ["food", "culture", "tech", "design"],
            "preferences": ["maxDistanceMiles": 25, "minPriceCents": 0, "maxPriceCents": 5000],
            "activeMode": "host",
            "onboardingComplete": true,
            "hostTagline": "Friendly gatherings for people new to Chicago",
            "hostThemeIds": ["social", "food", "art"],
            "isVerified": true,
            "hostRatingAvg": 0.0,
            "hostRatingCount": 0,
            "eventsHostedCount": 1,
            "guestsHostedCount": 0,
            "eventsAttendedCount": 0,
        ], forDocument: wunwan)

        let luciana = db.collection("users").document("user_luciana")
        batch.setData([
            "fullName": "Luciana Requena",
            "email": "luciana@example.com",
            "photoURL": "profilePhotos/user_luciana.jpg",
            "bio": "Peru - NYC - CMU 2027. New to Chicago. Looking for friends to explore the city.",
            "city": "Chicago",
            "interestIds": ["food", "sports", "tech", "art"],
            "preferences": ["maxDistanceMiles": 10, "minPriceCents": 0, "maxPriceCents": 10000],
            "activeMode": "guest",
            "onboardingComplete": true,
            "hostTagline": NSNull(),
            "hostThemeIds": [],
            "isVerified": false,
            "hostRatingAvg": 0.0,
            "hostRatingCount": 0,
            "eventsHostedCount": 0,
            "guestsHostedCount": 0,
            "eventsAttendedCount": 3,
        ], forDocument: luciana)

        let muskan = db.collection("users").document("user_muskan")
        batch.setData([
            "fullName": "Muskan Mankikar",
            "email": "muskan@example.com",
            "photoURL": "profilePhotos/user_muskan.jpg",
            "bio": "",
            "city": "Chicago",
            "interestIds": ["food", "culture", "tech", "design"],
            "preferences": ["maxDistanceMiles": 15, "minPriceCents": 0, "maxPriceCents": 5000],
            "activeMode": "guest",
            "onboardingComplete": true,
            "hostTagline": NSNull(),
            "hostThemeIds": [],
            "isVerified": false,
            "hostRatingAvg": 0.0,
            "hostRatingCount": 0,
            "eventsHostedCount": 0,
            "guestsHostedCount": 0,
            "eventsAttendedCount": 0,
        ], forDocument: muskan)

        // MARK: users/{uid}/savedEvents (subcollection)
        batch.setData(["savedAt": ts("2026-10-20 18:00")],
                      forDocument: luciana.collection("savedEvents").document("event_pasta101"))

        // MARK: friendships (doc ID = the two user IDs sorted and joined)
        let pair = ["user_luciana", "user_muskan"].sorted()
        batch.setData([
            "userIds": pair,
            "requesterId": "user_luciana",
            "status": "accepted",
            "createdAt": ts("2026-10-05 14:00"),
            "acceptedAt": ts("2026-10-05 15:00"),
        ], forDocument: db.collection("friendships").document(pair.joined(separator: "_")))

        // MARK: events
        let mixer = db.collection("events").document("event_rooftop_mixer")
        batch.setData([
            "hostId": "user_wunwan",
            "hostName": "Wunwan Boonsitanara",
            "hostPhotoURL": "profilePhotos/user_wunwan.jpg",
            "title": "Rooftop Welcome Mixer",
            "categoryId": "social",
            "description": "New to the city? Join us for a relaxed rooftop evening with easy conversation starters, snacks, and skyline views.",
            "coverPhotoURL": "eventCovers/event_rooftop_mixer.jpg",
            "startAt": ts("2026-10-24 18:30"),
            "endAt": ts("2026-10-24 21:00"),
            "rsvpDeadline": ts("2026-10-24 17:30"),
            "locationName": "Skyline Terrace",
            "address": "88 Spring Street, Chicago, IL",
            "neighborhood": "West Loop",
            "coordinates": GeoPoint(latitude: 41.8837, longitude: -87.6470),
            "capacity": 40,
            "priceCents": 0,
            "depositCents": 500,
            "cancellationHours": 24,
            "status": "live",
            "attendingCount": 2,
            "checkedInCount": 1,
            "createdAt": ts("2026-10-10 10:00"),
            "updatedAt": ts("2026-10-10 10:00"),
        ], forDocument: mixer)

        let pasta = db.collection("events").document("event_pasta101")
        batch.setData([
            "hostId": "user_wunwan",
            "hostName": "TUTORE - Italian Cooking School",
            "hostPhotoURL": NSNull(),
            "title": "Pasta 101 Class",
            "categoryId": "cooking",
            "description": "Learn to make fresh pasta from scratch, roll the dough, and shape it by hand.",
            "coverPhotoURL": "eventCovers/event_pasta101.jpg",
            "startAt": ts("2026-11-07 18:00"),
            "endAt": ts("2026-11-07 20:30"),
            "rsvpDeadline": ts("2026-11-06 18:00"),
            "locationName": "TUTORE",
            "address": "1629 W Grand Avenue, Chicago, IL",
            "neighborhood": "West Town",
            "coordinates": GeoPoint(latitude: 41.8912, longitude: -87.6683),
            "capacity": 12,
            "priceCents": 4500,
            "depositCents": 500,
            "cancellationHours": 48,
            "status": "live",
            "attendingCount": 0,
            "checkedInCount": 0,
            "createdAt": ts("2026-10-15 10:00"),
            "updatedAt": ts("2026-10-15 10:00"),
        ], forDocument: pasta)

        // MARK: events/{eventId}/rsvps (subcollection, doc ID = userId)
        batch.setData([
            "userId": "user_luciana",
            "eventId": "event_rooftop_mixer",
            "userName": "Luciana Requena",
            "userPhotoURL": "profilePhotos/user_luciana.jpg",
            "userInterestIds": ["food", "sports", "tech", "art"],
            "status": "checkedIn",
            "qrToken": UUID().uuidString,
            "paymentId": "mock_pay_001",
            "depositStatus": "refunded",
            "amountPaidCents": 500,
            "rsvpAt": ts("2026-10-18 20:00"),
            "cancelledAt": NSNull(),
            "checkedInAt": ts("2026-10-24 18:35"),
        ], forDocument: mixer.collection("rsvps").document("user_luciana"))

        batch.setData([
            "userId": "user_muskan",
            "eventId": "event_rooftop_mixer",
            "userName": "Muskan Mankikar",
            "userPhotoURL": "profilePhotos/user_muskan.jpg",
            "userInterestIds": ["food", "culture", "tech", "design"],
            "status": "attending",
            "qrToken": UUID().uuidString,
            "paymentId": "mock_pay_002",
            "depositStatus": "held",
            "amountPaidCents": 500,
            "rsvpAt": ts("2026-10-19 11:00"),
            "cancelledAt": NSNull(),
            "checkedInAt": NSNull(),
        ], forDocument: mixer.collection("rsvps").document("user_muskan"))

        // MARK: reviews (doc ID = eventId_reviewerId)
        batch.setData([
            "eventId": "event_rooftop_mixer",
            "hostId": "user_wunwan",
            "reviewerId": "user_luciana",
            "eventRating": 5,
            "hostRating": 5,
            "comment": "Super welcoming, met two people I'm getting coffee with next week.",
            "createdAt": ts("2026-10-25 10:00"),
        ], forDocument: db.collection("reviews").document("event_rooftop_mixer_user_luciana"))

        try await batch.commit()
        print("Seed complete")
    }
}
