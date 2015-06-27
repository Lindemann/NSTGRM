//
//  TableViewCell.swift
//  NSTGRM
//
//  Created by Lindemann on 24/06/15.
//  Copyright (c) 2015 Lindemann. All rights reserved.
//

import UIKit
import SwiftyJSON
import Haneke

class TableViewCell: UITableViewCell {

	var photoImageView: UIImageView = UIImageView()
	var photoInfo: SwiftyJSON.JSON = [] {
		didSet {
			setUpPhoto()
		}
	}
	
	func setUpPhoto() {
		// label.text = photoInfo["caption"]["text"].string
		if let urlString = photoInfo["images"]["standard_resolution"]["url"].string {
			
			photoImageView.frame = bounds
			
//			photoImageView.frame.size.height = photoImageView.frame.size.height - 4
//			photoImageView.frame.size.width = photoImageView.frame.size.width - 4
//			photoImageView.frame.origin.x = photoImageView.frame.origin.x + 2
//			photoImageView.frame.origin.y = photoImageView.frame.origin.y + 2
			
			photoImageView.contentMode = UIViewContentMode.ScaleAspectFit
			contentView.addSubview(photoImageView)
			
			let url = NSURL(string: urlString)
			let format = Format<UIImage>(name: "crop", diskCapacity: UInt64.max, transform: { (image) -> (UIImage) in
				return self.cropImage(image, toRect: CGRectMake(
					0,
					image.size.height/4,
					image.size.width,
					image.size.height/2)
				)
			})
			photoImageView.hnk_setImageFromURL(url!, format: format)

			
			
		}
	}

	override func prepareForReuse() {
		photoImageView.image = nil
	}

	func cropImage(image: UIImage, toRect rect: CGRect) -> UIImage {
		var imageRef: CGImageRef = CGImageCreateWithImageInRect(image.CGImage, rect)
		var croppedImage: UIImage = UIImage(CGImage:imageRef)!
		return croppedImage
	}

}

