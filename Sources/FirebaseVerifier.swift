import Foundation
import JWT

private let alghorithm = "RS256"
private let verifyIdTokenDocsMessage = "See https://firebase.google.com/docs/auth/admin/verify-id-tokens for details on how to retrieve an ID token."
private let projectIdMatchMessage = "Make sure the ID token comes from the same Firebase project as the service account used to authenticate this SDK."
enum VerificationErrorType {
    case
    emptyProjectId,
    notFound(key: String),
    incorrectAlgorithm,
    incorrectAudience,
    incorrectIssuer,
    noSub,
    expirationTimeIsNotFuture,
    issuedAtTimeIsNotPast
}

struct VerificationError: Error {
    let type: VerificationErrorType
    let message: String?
}

public struct VerifiedResult {
    let userId: String
    let authTime: Date
    // TODO: provider_id, firebase
}

public struct FirebaseVerifier {
    public let projectId: String
    init(projectId: String) throws {
        if projectId.isEmpty {
            throw VerificationError(type: .emptyProjectId, message: nil)
        }
        self.projectId = projectId
    }
    func verify(token: String, allowExpired: Bool = false) throws -> VerifiedResult {
        let jwt = try JWT(token: token)
        print("jwt: \(jwt)")

        guard let kid = jwt.keyIdentifier else {
            throw VerificationError(type: .notFound(key: "kid"), message: "Firebase ID token has no 'kid' claim.")
        }
        guard jwt.algorithmName == alghorithm else {
            let message = "Firebase ID token has incorrect algorithm. Expected '\(alghorithm)' but got '\(String(describing: jwt.algorithmName))'. \(verifyIdTokenDocsMessage)"
            throw VerificationError(type: .incorrectAlgorithm, message: message)
        }
        guard jwt.audience == projectId else {
            let message = "Firebase ID token has incorrect 'aud' (audience) claim. Expected '\(projectId)' but got '\(String(describing: jwt.audience))'. \(projectIdMatchMessage) \(verifyIdTokenDocsMessage)"
            throw VerificationError(type: .incorrectAudience, message: message)
        }
        guard jwt.issuer == "https://securetoken.google.com/\(projectId)" else {
            let message = "Firebase ID token has incorrect 'iss' (issuer) claim. Expected https://securetoken.google.com/\(projectId) but got '\(String(describing: jwt.issuer))'. \(projectIdMatchMessage) + \(verifyIdTokenDocsMessage)"
            throw VerificationError(type: .incorrectIssuer, message: message)
        }
        guard let subject = jwt.subject else {
            let message = "Firebase ID token has no 'sub' (subject) claim. \(verifyIdTokenDocsMessage)"
            throw VerificationError(type: .noSub, message: message)
        }
        guard subject.characters.count <= 128 else {
            let message = "Firebase ID token has 'sub' (subject) claim longer than 128 characters. \(verifyIdTokenDocsMessage)"
            throw VerificationError(type: .noSub, message: message)
        }
        guard let publicKey = try fetchPublicKeys()?[kid] as? String else {
            let message = "Firebase ID token has 'kid' claim which does not correspond to a known public key. Most likely the ID token is expired, so get a fresh token from your client app and try again. \(verifyIdTokenDocsMessage)"
            throw VerificationError(type: .notFound(key: "public key"), message: message)
        }

        assert(jwt.subject == jwt.userId)

        let publicKeyLines = publicKey.split(separator: "\n")
        let cert = String(publicKeyLines.prefix(through: publicKeyLines.count - 2).suffix(from: 1).joined())
            .makeBytes()
            .base64URLDecoded
        let signer = try RS256(x509Cert: cert)
        try jwt.verifySignature(using: signer)

        if !allowExpired {
            try jwt.verifyExpirationTime()
        }

        guard let authTime = jwt.expirationTime else { throw VerificationError(type: .notFound(key: "auth_time"), message: nil) }
        return VerifiedResult(userId: subject, authTime: authTime)
    }

    private func fetchPublicKeys() throws -> NSDictionary? {
        // TODO: Cache-Control
        let response = try String(contentsOf: URL(string: "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com")!)
        return response.toJSON() as? NSDictionary
    }
}

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

    func verifyExpirationTime() throws {
        guard let issuedAtTime = issuedAtTime else { throw VerificationError(type: .notFound(key: "iat"), message: nil) }
        guard let expirationTime = expirationTime else { throw VerificationError(type: .notFound(key: "exp"), message: nil) }
        let now = Date()
        if now < issuedAtTime {
            throw VerificationError(type: .issuedAtTimeIsNotPast,
                                    message: "'exp'(\(expirationTime)) must be in the future. (now: \(now)")
        }
        if now >= expirationTime {
            throw VerificationError(type: .expirationTimeIsNotFuture,
                                    message: "'exp'(\(expirationTime)) must be in the future. (now: \(now)")
        }
    }
}

extension String {
    func toJSON() -> Any? {
        guard let data = data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data)
    }
}
