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
    var intValue: Int?  // ✅ Stored property, not computed
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil  // ✅ Set it explicitly
    }
    
    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue  // ✅ Set it explicitly
    }
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
    
    private func keyedContainerForPath(_ path: [String]) -> (KeyedDecodingContainer<DynamicCodingKey>, DynamicCodingKey)? {
        print("🔍 keyedContainerForPath called with path: \(path)")
        
        guard !path.isEmpty else {
            print("❌ Path is empty")
            return nil
        }
        
        // Get root container
        guard let rootContainer = try? self.container(keyedBy: DynamicCodingKey.self) else {
            print("❌ Could not get root container")
            return nil
        }
        print("✅ Got root container")
        
        var currentContainer = rootContainer
        
        // Navigate through all keys except the last one
        for i in 0..<(path.count - 1) {
            guard let key = DynamicCodingKey(stringValue: path[i]) else {
                print("❌ Could not create key for: '\(path[i])'")
                return nil
            }
            
            print("🔍 Navigating to key: '\(key.stringValue)'")
            print("📋 Available keys at this level: \(currentContainer.allKeys.map { $0.stringValue })")
            
            guard let nested = try? currentContainer.nestedContainer(
                keyedBy: DynamicCodingKey.self,
                forKey: key
            ) else {
                print("❌ Could not get nested container for key: '\(key.stringValue)'")
                return nil
            }
            
            print("✅ Successfully navigated to '\(key.stringValue)'")
            currentContainer = nested
        }
        
        // Get the last key
        guard let lastKey = DynamicCodingKey(stringValue: path.last!) else {
            print("❌ Could not create last key: '\(path.last!)'")
            return nil
        }
        
        print("✅ Returning container with last key: '\(lastKey.stringValue)'")
        return (currentContainer, lastKey)
    }
    
    func safeStringDecode(_ keyPath: [String]) -> String {
        guard let (container, key) = keyedContainerForPath(keyPath) else {
            return ""
        }
        return (try? container.decodeIfPresent(String.self, forKey: key)) ?? ""
    }
    
    func safeNumDecode<T: Numeric & Decodable>(_ keyPath: [String]) -> T {
        guard let (container, key) = keyedContainerForPath(keyPath) else {
            return 0
        }
        return (try? container.decodeIfPresent(T.self, forKey: key)) ?? 0
    }
    
    func safeBoolDecode(_ keyPath: [String]) -> Bool {
        guard let (container, key) = keyedContainerForPath(keyPath) else {
            return false
        }
        return (try? container.decodeIfPresent(Bool.self, forKey: key)) ?? false
    }
    
    func safeURLDecode(_ keyPath: [String]) -> URL? {
        print("🔍 === Starting URL decode for path: \(keyPath) ===")
        
        guard let (container, key) = keyedContainerForPath(keyPath) else {
            print("❌ Could not get container for path: \(keyPath)")
            return nil
        }
        
        print("✅ Got container and key: \(key.stringValue)")
        
        // Check what keys are available in the container
        print("📋 Available keys in container: \(container.allKeys.map { $0.stringValue })")
        
        // Try decoding as URL directly
        do {
            if let url = try container.decodeIfPresent(URL.self, forKey: key) {
                print("✅ Decoded as URL: \(url.absoluteString)")
                return url
            } else {
                print("⚠️ decodeIfPresent returned nil for URL")
            }
        } catch {
            print("❌ Error decoding as URL: \(error)")
        }
        
        // Try decoding as String and converting to URL
        do {
            if let string = try container.decodeIfPresent(String.self, forKey: key) {
                print("✅ Decoded as String: '\(string)'")
                if let url = URL(string: string) {
                    print("✅ Converted to URL: \(url.absoluteString)")
                    return url
                } else {
                    print("❌ String is not a valid URL: '\(string)'")
                }
            } else {
                print("⚠️ decodeIfPresent returned nil for String")
            }
        } catch {
            print("❌ Error decoding as String: \(error)")
        }
        
        print("❌ Returning nil for path: \(keyPath)")
        return nil
    }
    func safeListDecode<T: Decodable>(_ keyPath: [String]) -> [T] {
        guard let (container, key) = keyedContainerForPath(keyPath) else {
            return []
        }
        
        if T.self == URL.self {
            if let arr = try? container.decodeIfPresent([URL].self, forKey: key) {
                return arr as! [T]
            }
            if let arr = try? container.decodeIfPresent([String].self, forKey: key) {
                return arr.compactMap { URL(string: $0) } as! [T]
            }
            return []
        }
        
        return (try? container.decodeIfPresent([T].self, forKey: key)) ?? []
    }
    
    func safeObjectDecode<T: Decodable>(_ keyPath: [String], defaultValue: T? = nil) -> T? {
        guard let (container, key) = keyedContainerForPath(keyPath) else {
            return defaultValue
        }
        return (try? container.decodeIfPresent(T.self, forKey: key)) ?? defaultValue
    }
}

