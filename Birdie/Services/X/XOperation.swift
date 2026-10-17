import Foundation

struct XOperation: Sendable {
    let name: String
    let queryID: String
    let method: String
    let features: [String: Bool]
    let relayVariables: [String: Bool]
    let endpoint: URL
    let isRelay: Bool

    init(name: String, queryID: String, method: String = "GET", features: [String: Bool] = [:],
         relayVariables: [String: Bool] = [:], endpoint: URL? = nil, isRelay: Bool = false) {
        self.name = name
        self.queryID = queryID
        self.method = method
        self.features = features
        self.relayVariables = relayVariables
        self.endpoint = endpoint ?? URL(string: "https://api.x.com")!.appending(path: "graphql/\(queryID)/\(name)")
        self.isRelay = isRelay
    }
}
