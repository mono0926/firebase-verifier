//
//  JWT+FirebaseVerifier.swift
//  Bits
//
//  Created by mono on 2017/08/03.
//

import Foundation

extension JWT {
    private func payloadStringValue(with key: String) -> String? {
        return payload[key]?.string
    }
    private func time(with key: String) -> Date? {
        guard let interval = payload[key]?.double else { return nil }
        return Date(timeIntervalSince1970: interval)
    }
    var issuedAtTime: Date? { return time(with: "iat") }
    var expirationTime: Date? { return time(with: "exp") }
    var authTime: Date? { return time(with: "auth_time") }
    var audience: String? { return payloadStringValue(with: "aud") }
    var issuer: String? { return payloadStringValue(with: "iss") }
    var subject: String? { return payloadStringValue(with: "sub") }
    var userId: String? { return payloadStringValue(with: "user_id") }

    func verifyAlgorithm() throws {
        let alghorithm = "RS256"
        if algorithmName == alghorithm { return }
        let message = "Firebase ID token has incorrect algorithm. Expected '\(alghorithm)' but got '\(String(describing: algorithmName))'. \(verifyIdTokenDocsMessage)"
        throw VerificationError(type: .incorrect(key: "alg"), message: message)
    }
    func verifyAudience(with projectId: String) throws {
        if audience == projectId { return }
        let message = "Firebase ID token has incorrect 'aud' (audience) claim. Expected '\(projectId)' but got '\(String(describing: audience))'. \(projectIdMatchMessage) \(verifyIdTokenDocsMessage)"
        throw VerificationError(type: .incorrect(key: "aud"), message: message)
    }
    func verifyIssuer(with projectId: String) throws {
        if issuer == "https://securetoken.google.com/\(projectId)" { return }
        let message = "Firebase ID token has incorrect 'iss' (issuer) claim. Expected https://securetoken.google.com/\(projectId) but got '\(String(describing: issuer))'. \(projectIdMatchMessage) + \(verifyIdTokenDocsMessage)"
        throw VerificationError(type: .incorrect(key: "iss"), message: message)
    }
    func verifyExpirationTime() throws {
        guard let issuedAtTime = issuedAtTime else { throw VerificationError(type: .notFound(key: "iat"), message: nil) }
        guard let expirationTime = expirationTime else { throw VerificationError(type: .notFound(key: "exp"), message: nil) }
        let now = Date()
        if now < issuedAtTime {
            throw VerificationError(type: .issuedAtTimeisFuture,
                                    message: "'iss'(\(issuedAtTime)) must be in the past. (now: \(now)")
        }
        if now >= expirationTime {
            throw VerificationError(type: .expirationTimeIsPast,
                                    message: "'exp'(\(expirationTime)) must be in the future. (now: \(now)")
        }
    }
}
