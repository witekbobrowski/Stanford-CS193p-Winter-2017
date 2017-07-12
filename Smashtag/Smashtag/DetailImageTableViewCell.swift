//
//  DetailImageTableViewCell.swift
//  Smashtag
//
//  Created by Witek on 12/07/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import UIKit

class DetailImageTableViewCell: UITableViewCell {

    @IBOutlet weak var detailImageView: UIImageView!
    
    var imageURL: URL? { didSet{ fetchImage() } }
    
    private func fetchImage() {
        if let url = imageURL {
            // Programming Assingment 4 : Task 9
            DispatchQueue.global(qos: .userInitiated).async{ [weak self] in
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.detailImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            detailImageView?.image = nil
        }
    }
    
}
