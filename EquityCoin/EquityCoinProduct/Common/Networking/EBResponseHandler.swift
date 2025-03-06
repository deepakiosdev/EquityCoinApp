//
//  EBResponseHandler.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation

protocol EBResponseHandler {
    func decode<T: Decodable>(_ data: Data) throws -> T
}
