//
//  EBJSONResponseHandler.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation

struct EBJSONResponseHandler: EBResponseHandler {
    func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            debugPrint("Parsing Error:\(error)")
            throw EBNetworkError
                .decodingFailed(description: error.localizedDescription)
        }
    }
}
