//
//  SafeDecode.swift
//  BBQuotes
//
//  Created by Moataz on 18/10/2025.
//
import Foundation


// DynamicCodingKey
struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { nil }
}

// MARK: - Enum-keyed helpers (use when you have an enum Key)
extension KeyedDecodingContainer {
    func safeStringDecode(forKey key: Key) -> String {
        (try? decodeIfPresent(String.self, forKey: key)) ?? ""
    }
    func safeNumDecode<T: Numeric & Decodable>(forKey key: Key) -> T {
        (try? decodeIfPresent(T.self, forKey: key)) ?? 0
    }
    func safeBoolDecode(forKey key: Key) -> Bool {
        (try? decodeIfPresent(Bool.self, forKey: key)) ?? false
    }
    func safeURLDecode(forKey key: Key) -> URL? {
        if let u = try? decodeIfPresent(URL.self, forKey: key) { return u }
        if let s = try? decodeIfPresent(String.self, forKey: key) { return URL(string: s) }
        return nil
    }
    func safeListDecode<T: Decodable>(forKey key: Key) -> [T] {
        if T.self == URL.self {
            if let arr = try? decodeIfPresent([URL].self, forKey: key) { return arr as! [T] }
            if let arr = try? decodeIfPresent([String].self, forKey: key) {
                return arr.compactMap { URL(string: $0) } as! [T]
            }
            return []
        }
        return (try? decodeIfPresent([T].self, forKey: key)) ?? []
    }
    func safeObjectDecode<T: Decodable>(forKey key: Key, defaultValue: T? = nil) -> T? {
        (try? decodeIfPresent(T.self, forKey: key)) ?? defaultValue
    }
}

// MARK: - Nested string-path helpers on Decoder (use for ["user","id"])
extension Decoder {
    // helper: walk path and return the keyed container at the final level (or nil)
    private func keyedContainerForPath(_ path: [String]) -> KeyedDecodingContainer<DynamicCodingKey>? {
        guard !path.isEmpty else { return nil }
        var currentDecoder: Decoder = self
        for (i, part) in path.enumerated() {
            guard let key = DynamicCodingKey(stringValue: part),
                  let container = try? currentDecoder.container(keyedBy: DynamicCodingKey.self)
            else { return nil }
            
            if i == path.count - 1 {
                return container
            } else if let nextDecoder = try? container.superDecoder(forKey: key) {
                currentDecoder = nextDecoder
            } else {
                return nil
            }
        }
        return nil
    }
    
    func safeStringDecode(_ keyPath: [String]) -> String {
        guard let container = keyedContainerForPath(keyPath),
              let lastKey = DynamicCodingKey(stringValue: keyPath.last!)
        else { return "" }
        
        return (try? container.decodeIfPresent(String.self, forKey: lastKey)) ?? ""
    }
    
    func safeNumDecode<T: Numeric & Decodable>(_ keyPath: [String]) -> T {
        guard let container = keyedContainerForPath(keyPath),
              let lastKey = DynamicCodingKey(stringValue: keyPath.last!)
        else { return 0 }
        return (try? container.decodeIfPresent(T.self, forKey: lastKey)) ?? 0
    }
    
    func safeBoolDecode(_ keyPath: [String]) -> Bool {
        guard let container = keyedContainerForPath(keyPath),
              let lastKey = DynamicCodingKey(stringValue: keyPath.last!)
        else { return false }
        return (try? container.decodeIfPresent(Bool.self, forKey: lastKey)) ?? false
    }
    
    func safeURLDecode(_ keyPath: [String]) -> URL? {
        guard let container = keyedContainerForPath(keyPath),
              let lastKey = DynamicCodingKey(stringValue: keyPath.last!)
        else { return nil }
        
        if let u = try? container.decodeIfPresent(URL.self, forKey: lastKey) { return u }
        if let s = try? container.decodeIfPresent(String.self, forKey: lastKey) { return URL(string: s) }
        return nil
    }
    
    func safeListDecode<T: Decodable>(_ keyPath: [String]) -> [T] {
        guard let container = keyedContainerForPath(keyPath),
              let lastKey = DynamicCodingKey(stringValue: keyPath.last!)
        else { return [] }
        
        if T.self == URL.self {
            if let arr = try? container.decodeIfPresent([URL].self, forKey: lastKey) { return arr as! [T] }
            if let arr = try? container.decodeIfPresent([String].self, forKey: lastKey) {
                return arr.compactMap { URL(string: $0) } as! [T]
            }
            return []
        }
        return (try? container.decodeIfPresent([T].self, forKey: lastKey)) ?? []
    }
    
    func safeObjectDecode<T: Decodable>(_ keyPath: [String], defaultValue: T? = nil) -> T? {
        guard let container = keyedContainerForPath(keyPath),
              let lastKey = DynamicCodingKey(stringValue: keyPath.last!)
        else { return defaultValue }
        return (try? container.decodeIfPresent(T.self, forKey: lastKey)) ?? defaultValue
    }
}


