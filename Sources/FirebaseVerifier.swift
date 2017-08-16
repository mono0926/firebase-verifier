import Foundation
import JWT

public protocol FirebaseVerifier {
    func verify(token: String, allowExpired: Bool) throws -> User
}

extension FirebaseVerifier {
    public func verify(token: String) throws -> User {
        return try verify(token: token, allowExpired: false)
    }
}

public struct FirebaseJWTVerifier: FirebaseVerifier {
    public let projectId: String
    public let publicCertificateFetcher: PublicCertificateFetcher
    public init(projectId: String, publicCertificateFetcher: PublicCertificateFetcher = GooglePublicCertificateFetcher()) throws {
        if projectId.isEmpty {
            throw VerificationError(type: .emptyProjectId, message: nil)
        }
        self.projectId = projectId
        self.publicCertificateFetcher = publicCertificateFetcher
    }
    public func verify(token: String, allowExpired: Bool = false) throws -> User {
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

        let cert = try publicCertificateFetcher.fetch(with: keyIdentifier).makeBytes().base64Decoded
        let signer = try RS256(x509Cert: cert)
        try jwt.verifySignature(using: signer)

        guard let authTime = jwt.expirationTime else { throw VerificationError(type: .notFound(key: "auth_time"), message: nil) }
        return User(jwt: jwt)
    }
}
