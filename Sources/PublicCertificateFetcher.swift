import Foundation

public protocol PublicCertificateFetcher {
    func fetch(with keyIdentifier: String) throws -> String
}

struct GooglePublicCertificateFetcher: PublicCertificateFetcher {
    func fetch(with keyIdentifier: String) throws -> String {
        // TODO: Cache-Control
        let response = try String(contentsOf: URL(string: "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com")!,
                                  encoding: .utf8)
        guard let certificates = response.toJSON() as? Dictionary<String, String> else {
            throw VerificationError(type: .notFound(key: "public key"), message: "response is not valid dictionary: \(response)")
        }
        return try fetch(with: keyIdentifier, from: certificates)
    }
    func fetch(with keyIdentifier: String, from certificates: Dictionary<String, String>) throws -> String {
        guard let publicCertificate = certificates[keyIdentifier] else {
            let message = "Firebase ID token has 'kid'(\(keyIdentifier)) claim which does not correspond to a known public key. Most likely the ID token is expired, so get a fresh token from your client app and try again. \(verifyIdTokenDocsMessage)"
            throw VerificationError(type: .notFound(key: "public key"), message: message)
        }
        guard let extracted = extractCertificate(from: publicCertificate) else {
            throw VerificationError(type: .notFound(key: "public key"), message: "Failed to extract publicCertificate from \(publicCertificate)")
        }
        return extracted
    }

    private func extractCertificate(from text: String) -> String? {
        return text.replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
    }
}
