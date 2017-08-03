//
//  String+FirebaseVerifier.swift
//  Bits
//
//  Created by mono on 2017/08/03.
//

import Foundation

extension String {
    func toJSON() -> Any? {
        guard let data = data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data)
    }
}
