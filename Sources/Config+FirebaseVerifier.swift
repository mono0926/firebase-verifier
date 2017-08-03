//
//  Config+FirebaseVerifier.swift
//  Bits
//
//  Created by mono on 2017/08/03.
//

import Foundation
import Vapor

extension FirebaseJWTVerifier: ConfigInitializable {
    public init(config: Config) throws {
        guard let firebase = config["firebase"] else {
            throw ConfigError.missingFile("firebase")
        }
        guard let projectId = firebase["project_id"]?.string else {
            throw ConfigError.missing(key: ["project_id"], file: "firebase", desiredType: String.self)
        }
        self = try FirebaseJWTVerifier(projectId: projectId)
    }
}

extension Config {
    public func resolveFirebaseVerifier() throws -> FirebaseVerifier {
        return try customResolve(
            unique: "firebase",
            file: "firebase",
            keyPath: ["verifier"],
            as: FirebaseVerifier.self,
            default: FirebaseJWTVerifier.init
        )
    }
}
