//
//  EBHostingTableViewCell.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import UIKit
import SwiftUI

final class EBHostingTableViewCell<Content: View>: UITableViewCell {
    
    private var hostingController: UIHostingController<Content>?
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func host(_ view: Content) {
        if let hostingController = hostingController {
            hostingController.rootView = view
            hostingController.view.setNeedsLayout()
        } else {
            let hostingController = UIHostingController(rootView: view)
            self.hostingController = hostingController
            
            contentView.addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            hostingController.view.backgroundColor = .clear
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hostingController?.view.removeFromSuperview()
        hostingController = nil
    }
}
