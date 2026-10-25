
import Foundation
import PlaygroundSupport
 
PlaygroundPage.current.needsIndefiniteExecution = true
 
// MARK: - Config
 
let stripeSecretKey = "API_KEY_HERE"
let baseURL = URL(string: "https://api.stripe.com/v1")!
 
// MARK: - Structs for Stripe's JSON responses
 
struct StripePaymentIntent: Decodable {
    let id: String              // "pi_..."; stored on the RSVP as paymentId
    let amount: Int             // in cents, 500 = $5.00
    let currency: String
    let status: String          // "succeeded" when the deposit is collected
    let created: Int            // Unix timestamp
    let metadata: [String: String]
}
 
struct StripeRefund: Decodable {
    let id: String              // "re_..."
    let amount: Int
    let currency: String
    let status: String          // "succeeded" when the refund is issued
    let paymentIntent: String   // the PaymentIntent that was refunded
    let created: Int
 
    enum CodingKeys: String, CodingKey {
        case id, amount, currency, status, created
        case paymentIntent = "payment_intent"
    }
}
 
struct StripeErrorResponse: Decodable {
    struct Detail: Decodable {
        let message: String
        let type: String
    }
    let error: Detail
}
 
enum StripeError: Error {
    case api(String)
}
 
// MARK: - Request helper
 
// Stripe takes form-encoded bodies and returns JSON.
func stripePost<T: Decodable>(_ path: String, _ params: [String: String], as type: T.Type) async throws -> T {
    var request = URLRequest(url: baseURL.appendingPathComponent(path))
    request.httpMethod = "POST"
    request.setValue("Bearer \(stripeSecretKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
 
    var components = URLComponents()
    components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
    request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
 
    let (data, response) = try await URLSession.shared.data(for: request)
    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
 
    print("\n--- Raw JSON from POST /v1/\(path) (HTTP \(statusCode)) ---")
    print(String(data: data, encoding: .utf8) ?? "")
 
    guard (200..<300).contains(statusCode) else {
        let apiError = try? JSONDecoder().decode(StripeErrorResponse.self, from: data)
        throw StripeError.api(apiError?.error.message ?? "HTTP \(statusCode)")
    }
    return try JSONDecoder().decode(T.self, from: data)
}
 
// MARK: - The two calls our app needs
 
/// Guest reserves a spot: collect the deposit
func collectDeposit(cents: Int, eventId: String, userId: String) async throws -> StripePaymentIntent {
    try await stripePost("payment_intents", [
        "amount": String(cents),
        "currency": "usd",
        "payment_method": "pm_card_visa",
        "automatic_payment_methods[enabled]": "true",
        "automatic_payment_methods[allow_redirects]": "never",
        "confirm": "true",
        "description": "RSVP deposit",
        "metadata[eventId]": eventId,
        "metadata[userId]": userId,
    ], as: StripePaymentIntent.self)
}
 
/// Host checks the guest in: refund the deposit
func refundDeposit(paymentIntentId: String) async throws -> StripeRefund {
    try await stripePost("refunds", [
        "payment_intent": paymentIntentId,
    ], as: StripeRefund.self)
}
 
// MARK: - Run the flow
 
func money(_ cents: Int) -> String { String(format: "$%.2f", Double(cents) / 100) }
 
Task {
    do {
//        print("1. Guest RSVPs to event_rooftop_mixer, collecting the deposit...")
//        let payment = try await collectDeposit(cents: 500,
//                                               eventId: "event_rooftop_mixer",
//                                               userId: "user_muskan")
//        print("\nParsed StripePaymentIntent:")
//        print("  id:       \(payment.id)")
//        print("  amount:   \(money(payment.amount)) \(payment.currency.uppercased())")
//        print("  status:   \(payment.status)")
//        print("  metadata: \(payment.metadata)")
//        print("  -> Save \(payment.id) as rsvps/user_muskan.paymentId, depositStatus = \"held\"")
// 
        print("\n2. Host checks the guest in, refunding the deposit...")
        let refund = try await refundDeposit(paymentIntentId: "pi_3UUTmR38JhxoPi8D0k11QHIf")
        print("\nParsed StripeRefund:")
        print("  id:             \(refund.id)")
        print("  amount:         \(money(refund.amount)) \(refund.currency.uppercased())")
        print("  status:         \(refund.status)")
        print("  payment_intent: \(refund.paymentIntent)")
        print("  -> Set rsvps/user_muskan.depositStatus = \"refunded\"")
    } catch {
        print("\nStripe call failed: \(error)")
    }
    PlaygroundPage.current.finishExecution()
}
 
