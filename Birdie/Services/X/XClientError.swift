import Foundation

enum XClientError: LocalizedError, Equatable {
    case signedOut
    case sessionExpired
    case rateLimited
    case httpStatus(Int)
    case apiError
    case invalidResponse
    case operationUnavailable
    case credentialStorage

    var errorDescription: String? {
        switch self {
        case .signedOut: "Sign in to X to continue."
        case .sessionExpired: "Your X session has expired. Please sign in again."
        case .rateLimited: "X is limiting requests. Please try again in a few minutes."
        case .httpStatus: "X couldn’t complete this request. Please try again."
        case .apiError: "X couldn’t complete this action. Please try again."
        case .invalidResponse: "X returned an unexpected response. Please try again."
        case .operationUnavailable: "X has changed its web API. Sign in again to refresh the connection."
        case .credentialStorage: "Birdie couldn’t securely save your session. Please try signing in again."
        }
    }
}
