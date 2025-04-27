//
//  MockDataFetchable.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 27/04/25.
//

import Foundation

struct MockDataFetchable {
    static private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    

    static func loadMockData<T: Decodable>(fileName: String) -> T? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            debugPrint("⚠️ Unable to find JSON file: \(fileName)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decodedData = try jsonDecoder.decode(T.self, from: data)
            return decodedData
        } catch {
            debugPrint("⚠️ Error decoding JSON: \(error)")
            return nil
        }
    }
}
