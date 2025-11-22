//
//  NetworkLogger.swift
//  BBQuotes
//
//  Created by Moataz on 19/10/2025.
//

import Foundation

enum NetworkLogger {
    static func logRequest(_ request: URLRequest) {
        print("\n🚀 [REQUEST START]")
        print("➡️ URL: \(request.url?.absoluteString ?? "❌ No URL")")
        print("➡️ Method: \(request.httpMethod ?? "❌ No Method")")
        
        if let headers = request.allHTTPHeaderFields {
            print("📋 Headers:")
            print(prettyJSONString(from: headers) ?? "❌ Unable to format headers")
        }
        
        if let body = request.httpBody {
            print("📦 Body:")
            print(prettyJSONString(from: body) ?? String(data: body, encoding: .utf8) ?? "❌ Unable to decode body")
        }
        
        print("🚀 [REQUEST END]\n")
    }
    
    static func logResponse(_ response: URLResponse?, data: Data?) {
        print("\n📬 [RESPONSE START]")
        
        if let httpResponse = response as? HTTPURLResponse {
            print("✅ Status Code: \(httpResponse.statusCode)")
            print("📍 URL: \(httpResponse.url?.absoluteString ?? "❌ No URL")")
            
            print("📋 Headers:")
            print(prettyJSONString(from: httpResponse.allHeaderFields) ?? "❌ Unable to format headers")
        } else {
            print("❌ No valid HTTP response")
        }
        
        if let data = data {
            print("🧾 Body:")
            print(prettyJSONString(from: data) ?? String(data: data, encoding: .utf8) ?? "❌ Unable to decode response body")
        }
        
        print("📬 [RESPONSE END]\n")
    }
    
    static func logError(_ error: Error) {
        print("🔥 [ERROR]: \(error.localizedDescription)")
    }
    
    private static func prettyJSONString(from data: Data) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyString = String(data: prettyData, encoding: .utf8)
        else { return nil }
        return prettyString
    }
    
    private static func prettyJSONString(from dictionary: [AnyHashable: Any]) -> String? {
        guard JSONSerialization.isValidJSONObject(dictionary),
              let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted]),
              let string = String(data: data, encoding: .utf8)
        else { return nil }
        return string
    }
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum NetworkHelper {
    // Request without a body
    static func request<T: Decodable>(
        url: URL,
        method: HttpMethod = .get,
        queryParams: [URLQueryItem]? = nil,
        headers: [String: String]? = nil,
        responseKey: String? = nil,
        responseType: T.Type
    ) async throws -> (T, HTTPURLResponse) {
        
        var finalURL = url
        if let queryItems = queryParams {
            finalURL = finalURL.appending(queryItems: queryItems)
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        NetworkLogger.logRequest(request)
        let (data, response) = try await URLSession.shared.data(for: request)
//        NetworkLogger.logResponse(response, data: data)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else { throw URLError(.badServerResponse) }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        if let key = responseKey {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard let dict = jsonObject as? [String: Any],
                  let nestedData = dict[key] else {
                throw URLError(.cannotParseResponse)
            }
            let nestedJsonData = try JSONSerialization.data(withJSONObject: nestedData)
            return try (decoder.decode(T.self, from: nestedJsonData), httpResponse)
        } else {
            return try (decoder.decode(T.self, from: data), httpResponse)
        }
    }
    
    // Request with an Encodable body
    static func request<T: Decodable, B: Encodable>(
        url: URL,
        method: HttpMethod = .post,
        queryItems: [URLQueryItem]? = nil,
        body: B,
        headers: [String: String]? = nil,
        responseKey: String? = nil,
        responseType: T.Type
    ) async throws -> (T, HTTPURLResponse) {
        
        var finalURL = url
        if let queryItems = queryItems {
            finalURL = finalURL.appending(queryItems: queryItems)
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        NetworkLogger.logRequest(request)
        let (data, response) = try await URLSession.shared.data(for: request)
        NetworkLogger.logResponse(response, data: data)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else { throw URLError(.badServerResponse) }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        if let key = responseKey {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard let dict = jsonObject as? [String: Any],
                  let nestedData = dict[key] else {
                throw URLError(.cannotParseResponse)
            }
            let nestedJsonData = try JSONSerialization.data(withJSONObject: nestedData)
            return try (decoder.decode(T.self, from: nestedJsonData), httpResponse)
        } else {
            return try (decoder.decode(T.self, from: data), httpResponse)
        }
    }
}

