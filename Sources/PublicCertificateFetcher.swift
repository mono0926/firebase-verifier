import Foundation

public protocol PublicCertificateFetcher {
    func fetch(with keyIdentifier: String) throws -> String
}

struct GooglePublicCertificateFetcher: PublicCertificateFetcher {
    func fetch(with keyIdentifier: String) throws -> String {
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
    }
}
