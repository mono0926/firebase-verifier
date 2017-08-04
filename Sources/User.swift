//
//  VerifiedResult.swift
//  Bits
//
//  Created by mono on 2017/08/03.
//

import Foundation

public struct User {
    public let id: String
    public let authTime: Date
    // TODO: provider_id, firebase
    public init(id: String, authTime: Date) {
        self.id = id
        self.authTime = authTime
    }
}
