//
//  EBCoinRankingService.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation
import Network

//https://developers.coinranking.com/api/documentation/coins/coins
/*
 Default query parameters:
 1. timePeriod = 24 hr
 2. orderBy = marketCap
 3. orderDirection = desc
 
 */
final class EBCoinRankingService: EBCoinServiceProtocol {
    private let networkService: EBNetworkService
    private let monitor: NWPathMonitor
    private var isConnected: Bool = false
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    init(networkService: EBNetworkService = EBNetworkManager()) {
        self.networkService = networkService
        self.monitor = NWPathMonitor()
        
        let queue = DispatchQueue(label: "com.equitycoin.networkmonitor")
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        
        isConnected = monitor.currentPath.status == .satisfied
    }
    
    func fetchCoins(page: Int, limit: Int) async throws -> [EBCoin] {
        guard isConnected else {
            throw EBNetworkError.noInternet
        }
        let offset = (page - 1) * limit
        let request = EBCoinRequest(
            path: "/v2/coins",
            queryParameters: ["offset": "\(offset)", "limit": "\(limit)"]
        )
        
        // Print curl command for debugging
        printCurlCommand(for: request)
        
        do {
            let (data, response) = try await networkService.performRequest(request)
            debugPrint("Network response for \(request.url?.absoluteString ?? "Unknown URL"): \(response)")
            let decodedResponse = try jsonDecoder.decode(EBCoinResponse.self, from: data)
            guard decodedResponse.status == "success" else {
                throw EBNetworkError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            return decodedResponse.data.coins
        } catch {
            throw handleDecodingError(error, for: "fetchCoins")
        }
    }
    
    func fetchCoinHistory(coinId: String, timePeriod: String) async throws -> [EBCoinHistory] {
        guard isConnected else {
            throw EBNetworkError.noInternet
        }
        let request = EBCoinRequest(
            path: "/v2/coin/\(coinId)/history",
            queryParameters: ["timePeriod": timePeriod]
        )
        
        // Print curl command for debugging
        printCurlCommand(for: request)
        
        do {
            let (data, response) = try await networkService.performRequest(request)
            debugPrint("Network response for \(request.url?.absoluteString ?? "Unknown URL"): \(response)")
            let decodedResponse = try jsonDecoder.decode(EBCoinHistoryResponse.self, from: data)
            guard decodedResponse.status == "success" else {
                throw EBNetworkError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            return decodedResponse.data.history
        } catch {
            throw handleDecodingError(error, for: "fetchCoinHistory")
        }
    }
    
    private func handleDecodingError(_ error: Error, for method: String) -> Error {
        if let decodingError = error as? DecodingError {
            debugPrint("Decoding error in \(method): \(decodingError)")
            return EBNetworkError.decodingFailed(description: decodingError.localizedDescription)
        }
        return error
    }
    
    // Function to print curl command for debugging
    private func printCurlCommand(for request: EBCoinRequest) {
        guard let url = request.url else { return }
        var curlCommand = "curl -X \(request.method.rawValue) \"\(url.absoluteString)\""
        
        if let headers = request.headers {
            for (key, value) in headers {
                curlCommand += " -H \"\(key): \(value)\""
            }
        }
        
        debugPrint("CURL Command: \(curlCommand)")
    }
}
