//
//  VerifiedResult.swift
//  Bits
//
//  Created by mono on 2017/08/03.
//

import Foundation
import JWT

public struct Firebase {
    public let identities: [String: [String]]
    public let signInProvider: String

    init(json: JSON) {
        identities = json["identities"]!.object!
            .reduce([String: [String]]()) { sum, e in
                var sum = sum
                sum[e.key] = e.value.array!.map { $0.string! }
                return sum
        }
        signInProvider = json["sign_in_provider"]!.string!
    }

    public init(identities: [String: [String]], signInProvider: String) {
        self.identities = identities
        self.signInProvider = signInProvider
    }
}

public struct User {
    public let id: String
    public let authTime: Date
    public let issuedAtTime: Date
    public let expirationTime: Date
    public let email: String?
    public let emailVerified: Bool?
    public let firebase: Firebase

    public init(id: String,
                authTime: Date,
                issuedAtTime: Date,
                expirationTime: Date,
                email: String? = nil,
                emailVerified: Bool? = nil,
                firebase: Firebase = Firebase(identities: [:], signInProvider: "")) {
        self.id = id
        self.authTime = authTime
        self.issuedAtTime = issuedAtTime
        self.expirationTime = expirationTime
        self.email = email
        self.emailVerified = emailVerified
        self.firebase = firebase
    }

    public init(jwt: JWT) {
        self.init(id: jwt.userId!,
                  authTime: jwt.authTime!,
                  issuedAtTime: jwt.issuedAtTime!,
                  expirationTime: jwt.expirationTime!,
                  email: jwt.email,
                  emailVerified: jwt.emailVerified,
                  firebase: Firebase(json: jwt.payload["firebase"]!))
    }
}
