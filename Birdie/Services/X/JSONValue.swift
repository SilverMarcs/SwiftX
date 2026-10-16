import Foundation

/// A Sendable boundary for X's evolving GraphQL unions. Only the parser knows
/// their field names; views and stores use the app's concrete models.
nonisolated enum JSONValue: Decodable, Sendable {
    case object([String: JSONValue])
    case array([JSONValue])
    case string(String)
    case number(Double)
    case bool(Bool)
    case null

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { self = .null }
        else if let value = try? container.decode(Bool.self) { self = .bool(value) }
        else if let value = try? container.decode(String.self) { self = .string(value) }
        else if let value = try? container.decode(Double.self) { self = .number(value) }
        else if let value = try? container.decode([String: JSONValue].self) { self = .object(value) }
        else { self = .array(try container.decode([JSONValue].self)) }
    }

    subscript(_ key: String) -> JSONValue {
        if case .object(let values) = self { values[key] ?? .null } else { .null }
    }

    var array: [JSONValue] { if case .array(let values) = self { values } else { [] } }
    var string: String? { if case .string(let value) = self { value } else { nil } }
    var bool: Bool? { if case .bool(let value) = self { value } else { nil } }
    var number: Double? {
        switch self {
        case .number(let value): value
        case .string(let value): Double(value)
        default: nil
        }
    }
    var int: Int? {
        guard let value = number, value.isFinite, value >= Double(Int.min), value < Double(Int.max) else { return nil }
        return Int(value)
    }
    var isNull: Bool { if case .null = self { true } else { false } }

    func at(_ path: String) -> JSONValue {
        path.split(separator: ".").reduce(self) { $0[String($1)] }
    }
}
