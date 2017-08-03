import Foundation
import JWT

public protocol FirebaseVerifier {
    func verify(token: String, allowExpired: Bool) throws -> VerifiedResult
}

extension FirebaseVerifier {
    public func verify(token: String) throws -> VerifiedResult {
        return try verify(token: token, allowExpired: false)
    }
}

public struct FirebaseJWTVerifier: FirebaseVerifier {
    public let projectId: String
    public init(projectId: String) throws {
        if projectId.isEmpty {
            throw VerificationError(type: .emptyProjectId, message: nil)
        }
        self.projectId = projectId
    }
    public func verify(token: String, allowExpired: Bool = false) throws -> VerifiedResult {
        let jwt = try JWT(token: token)

        assert(jwt.subject == jwt.userId)
        if !allowExpired {
            try jwt.verifyExpirationTime()
        }
        try jwt.verifyAlgorithm()
        try jwt.verifyAudience(with: projectId)
        try jwt.verifyIssuer(with: projectId)

        guard let keyIdentifier = jwt.keyIdentifier else {
            throw VerificationError(type: .notFound(key: "kid"), message: "Firebase ID token has no 'kid' claim.")
        }

        guard let subject = jwt.subject else {
            let message = "Firebase ID token has no 'sub' (subject) claim. \(verifyIdTokenDocsMessage)"
            throw VerificationError(type: .notFound(key: "sub"), message: message)
        }
        guard subject.characters.count <= 128 else {
            let message = "Firebase ID token has 'sub' (subject) claim longer than 128 characters. \(verifyIdTokenDocsMessage)"
            throw VerificationError(type: .incorrect(key: "sub"), message: message)
        }

        let cert = try fetchPublicCertificate(with: keyIdentifier)
        let signer = try RS256(x509Cert: cert)
        try jwt.verifySignature(using: signer)

        guard let authTime = jwt.expirationTime else { throw VerificationError(type: .notFound(key: "auth_time"), message: nil) }
        return VerifiedResult(userId: subject, authTime: authTime)
    }

    private func fetchPublicCertificate(with keyIdentifier: String) throws -> Bytes {
        // TODO: Cache-Control
        let response = try String(contentsOf: URL(string: "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com")!,
                                  encoding: .utf8)

        guard let keys = response.toJSON() as? Dictionary<String, String>, let publicKey = keys[keyIdentifier] else {
            let message = "Firebase ID token has 'kid'(\(keyIdentifier)) claim which does not correspond to a known public key. Most likely the ID token is expired, so get a fresh token from your client app and try again. \(verifyIdTokenDocsMessage)"
            throw VerificationError(type: .notFound(key: "public key"), message: message)
        }

        let publicKeyLines = publicKey.characters.split(separator: "\n")
        assert(publicKeyLines.count >= 3)
        return String(publicKeyLines[1..<publicKeyLines.count - 1].joined())
            .makeBytes()
            .base64URLDecoded
    }
}
