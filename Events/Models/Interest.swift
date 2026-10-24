//
//  Interest.swift
//  Firestore: interests/{interestId}
//

import Foundation
import FirebaseFirestore

struct Interest: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var parentId: String?          // nil = top level, set = subcategory
    var sortOrder: Int

    var isSubcategory: Bool { parentId != nil }
}
