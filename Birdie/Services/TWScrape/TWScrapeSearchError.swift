import Foundation

enum TWScrapeSearchError: LocalizedError {
    case missingCredentials
    case httpStatus(Int)
    case apiError
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            "Add your X cookie and authorization header in Settings → Authentication."
        case .httpStatus(401), .httpStatus(403):
            "X rejected this session. Update your X credentials in Settings → Authentication."
        case .httpStatus(429):
            "X is limiting searches. Wait a little and try again."
        case .httpStatus(404):
            "X's search endpoint has changed. Birdie needs an update to search again."
        case .httpStatus(let status):
            "X couldn't complete the search (HTTP \(status)). Try again."
        case .apiError:
            "X couldn't complete the search. Try again or update your X credentials."
        case .invalidResponse:
            "Birdie couldn't read X's search response. The search format may have changed."
        }
    }
}
