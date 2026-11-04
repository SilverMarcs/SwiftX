import Foundation

/// Public wire metadata for one operation name, including older names still observed at login.
struct XOperationDefinition: Sendable {
    let name: String
    let canonicalName: String
    let queryID: String?
    let method: String
    let isRelay: Bool
    let isMutation: Bool
    let relayVariables: [String: Bool]
    let fieldToggles: [String: Bool]
    let assetPrefixes: [String]

    init(_ name: String, canonicalName: String? = nil, queryID: String? = nil,
         method: String = "GET", isRelay: Bool = true, isMutation: Bool = false,
         relayVariables: [String: Bool] = [:], fieldToggles: [String: Bool] = [:],
         assetPrefixes: [String] = []) {
        self.name = name
        self.canonicalName = canonicalName ?? name
        self.queryID = queryID
        self.method = method
        self.isRelay = isRelay
        self.isMutation = isMutation
        self.relayVariables = relayVariables
        self.fieldToggles = fieldToggles
        self.assetPrefixes = assetPrefixes
    }

    func operation(queryID: String, isRelay: Bool? = nil, endpoint: URL? = nil,
                   features: [String: Bool] = [:], relayVariables: [String: Bool]? = nil,
                   fieldToggles: [String: Bool]? = nil) -> XOperation {
        let relay = isRelay ?? self.isRelay
        return XOperation(name: name, queryID: queryID, method: method, features: features,
                          relayVariables: relay ? (relayVariables ?? self.relayVariables) : [:],
                          fieldToggles: relay ? [:] : (fieldToggles ?? self.fieldToggles),
                          endpoint: endpoint, isRelay: relay, isMutation: isMutation)
    }
}
