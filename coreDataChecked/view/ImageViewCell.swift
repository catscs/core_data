//
//  ImageViewCell.swift
//  coreDataChecked
//
//  Created by Félix Luján Albarrán on 6/2/21.
//

import UIKit

class ImageViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(image: UIImage) {
        imageView.image = image
    }
}
