//
//  VerifiedResult.swift
//  Bits
//
//  Created by mono on 2017/08/03.
//

import Foundation

public struct VerifiedResult {
    public let userId: String
    public let authTime: Date
    // TODO: provider_id, firebase
    public init(userId: String, authTime: Date) {
        self.userId = userId
        self.authTime = authTime
    }
}
