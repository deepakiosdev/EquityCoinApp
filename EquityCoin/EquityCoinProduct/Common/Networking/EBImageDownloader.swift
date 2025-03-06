//
//  EBImageDownloader.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 06/03/25.
//


import SwiftUI
import Combine

class EBImageDownloader: ObservableObject {
    @Published var image: UIImage?
    @Published var svgData: Data?
    private var cancellables = Set<AnyCancellable>()
    private let cache = NSCache<NSString, UIImage>()
    
    func loadImage(from urlString: String?) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            print("Invalid URL: \(String(describing: urlString))")
            DispatchQueue.main.async { [weak self] in
                self?.image = UIImage(named: "defaultCrypto")
                self?.svgData = nil
            }
            return
        }
        
        // Check cache first (for raster images only)
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async { [weak self] in
                self?.image = cachedImage
                self?.svgData = nil
            }
            return
        }
        
        // Download image
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> (UIImage?, Data?) in
                let pathExtension = url.pathExtension.lowercased()
                print("Downloading image from: \(urlString), type: \(pathExtension)")
                
                switch pathExtension {
                case "svg":
                    return (nil, data)
                    
                case "png", "jpg", "jpeg":
                    guard let image = UIImage(data: data) else {
                        throw URLError(.badServerResponse)
                    }
                    return (image, nil)
                    
                default:
                    print("Unsupported image type: \(pathExtension)")
                    return (nil, nil)
                }
            }
            .replaceError(with: (nil, nil))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (image, svgData) in
                guard let self = self else { return }
                if let image = image {
                    self.image = image
                    self.svgData = nil
                    self.cache.setObject(image, forKey: urlString as NSString)
                } else if let svgData = svgData {
                    self.image = nil
                    self.svgData = svgData
                } else {
                    print("Failed to process image for: \(urlString)")
                    self.image = UIImage(named: "defaultCrypto")
                    self.svgData = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func cancel() {
        cancellables.forEach { $0.cancel() }
    }
    
    deinit {
        cancel()
    }
}
