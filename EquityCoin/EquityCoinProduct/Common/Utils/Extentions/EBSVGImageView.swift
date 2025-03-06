//
//  EBSVGImageView.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 06/03/25.
//

import SwiftUI
import WebKit

struct EBSVGImageView: UIViewRepresentable {
    let svgData: Data?
    let size: CGSize
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let svgData = svgData,
              let svgString = String(data: svgData, encoding: .utf8) else {
            return
        }
        
        let htmlString = """
        <html>
        <head>
        <style>
        body { margin: 0; padding: 0; background: transparent; }
        svg { 
            width: \(100)px; 
            height: \(100)px; 
            max-width: 100%; 
            max-height: 100%; 
            object-fit: contain;
        }
        </style>
        </head>
        <body>
        \(svgString)
        </body>
        </html>
        """
        
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}
