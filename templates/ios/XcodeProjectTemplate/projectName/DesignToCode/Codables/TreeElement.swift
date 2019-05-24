// based on codes generated by https://app.quicktype.io/
// To parse the JSON, add this file to your project and do:
//
//   let tree = try Tree(json)

import Foundation

typealias Tree = [TreeElement]

struct TreeElement: Codable {
    let uid, name: String?
    let elements: [TreeElement]?
    let properties: DtcProperties?
    let shuoldExcludeOnAdopt: Bool
}

// MARK: Convenience initializers and mutators

extension TreeElement {

    private enum CodingKeys: CodingKey {
        case uid, name, elements, properties, shuoldExcludeOnAdopt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        uid = try container.decode(String.self, forKey: .uid)
        name = try container.decode(String.self, forKey: .name)
        elements = try container.decode([TreeElement].self, forKey: .elements)
        shuoldExcludeOnAdopt = try container.decode(Bool.self, forKey: .shuoldExcludeOnAdopt)
        let properties = try ContainerProps.init(from: container.superDecoder(forKey: .properties))
        self.properties = try properties.type.metatype.init(from: container.superDecoder(forKey: .properties))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(uid, forKey: .uid)
        try container.encode(name, forKey: .name)
        try container.encode(elements, forKey: .elements)
        try properties?.encode(to: container.superEncoder(forKey: .properties))
    }

    init(data: Data) throws {
        self = try newJSONDecoder().decode(TreeElement.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        uid: String?? = nil,
        name: String?? = nil,
        elements: [TreeElement]?? = nil,
        properties: DtcProperties?? = nil
        ) -> TreeElement {
        return TreeElement(
            uid: uid ?? self.uid,
            name: name ?? self.name,
            elements: elements ?? self.elements,
            properties: properties ?? self.properties,
            shuoldExcludeOnAdopt: shuoldExcludeOnAdopt
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }

    func getUids(_ uids: inout [String]) {
        if let uid = self.uid {
            uids.append(uid)
        }
        if let elements = self.elements, !elements.isEmpty {
            for element in elements {
                element.getUids(&uids)
            }
        }
    }
}

// Codable related
extension Array where Element == Tree.Element {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Tree.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

fileprivate func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

fileprivate func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// Utility
extension Array where Element == Tree.Element {
    /// lookup TreeElement that matches uid, and returns DtcProperties the element has
    func getProperty(_ pathName: String, _ parentName: String? = nil) -> DtcProperties? {
        for element in self {
            guard let name = element.name else { continue }
            let currentName: String = parentName != nil ? parentName! + "." + name : name
            if currentName == pathName {
                return element.properties
            }
            if
                let elements = element.elements,
                let props = elements.getProperty(pathName, currentName) {
                return props
            }
        }
        return nil
    }
}
