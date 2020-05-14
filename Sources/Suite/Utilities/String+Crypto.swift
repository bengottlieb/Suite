//
//  String+Crypto.swift
//  
//
//  Created by Ben Gottlieb on 4/6/20.
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension String {
    var sha256: String {
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }

}
#endif

