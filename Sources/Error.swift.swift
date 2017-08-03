//
//  Error.swift.swift
//  Bits
//
//  Created by mono on 2017/08/03.
//

import Foundation

let verifyIdTokenDocsMessage = "See https://firebase.google.com/docs/auth/admin/verify-id-tokens for details on how to retrieve an ID token."
let projectIdMatchMessage = "Make sure the ID token comes from the same Firebase project as the service account used to authenticate this SDK."

public enum VerificationErrorType {
    case
    notFound(key: String),
    incorrect(key: String),
    emptyProjectId,
    expirationTimeIsPast,
    issuedAtTimeisFuture
}

public struct VerificationError: Error {
    public let type: VerificationErrorType
    public let message: String?
}

extension VerificationError: CustomStringConvertible {
    public var description: String {
        return "type: \(type)\nmessage: \(String(describing: message))"
    }
}
