import Foundation

nonisolated enum XAPIError: LocalizedError, Equatable {
    case missingSession
    case sessionExpired
    case rateLimited(Date?)
    case operationUnavailable
    case responseChanged
    case server(Int)
    case keychain(Int32)

    var errorDescription: String? {
        switch self {
        case .missingSession: "Add your X session cookie and authorization header in Settings."
        case .sessionExpired: "Your X session has expired or needs verification. Update it in Settings."
        case .rateLimited(let reset):
            if let reset { "X has temporarily limited requests. Try again after \(reset.formatted(date: .omitted, time: .shortened))." }
            else { "X has temporarily limited requests. Try again later." }
        case .operationUnavailable: "X has changed this request. Its web operation needs updating."
        case .responseChanged: "X returned an unexpected response. Try again, or update Birdie if this continues."
        case .server(let status): "X couldn’t complete the request (HTTP \(status)). Try again."
        case .keychain: "Your session couldn’t be saved securely. Check Keychain access and try again."
        }
    }
}
