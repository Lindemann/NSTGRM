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
			setupPhoto()
			setupLikes()
		}
	}
	
	func setupPhoto() {
		// label.text = photoInfo["caption"]["text"].string
		if let urlString = photoInfo["images"]["standard_resolution"]["url"].string {
			
			photoImageView.frame = bounds
			
			// White frame for photos
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
	
	func setupLikes() {
		let likes = photoInfo["likes"]["count"]
		
		let label = UILabel(frame: CGRectMake(0, 0, 0, 0))
		label.text = "♥︎ \(likes)"
		label.sizeToFit()
		label.textColor = UIColor.darkGrayColor()
		let likesViewWidth = (label.bounds.size.width + 40 >= 80) ? label.bounds.size.width + 40 : 80
		let likesView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) as UIVisualEffectView
		likesView.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.4)
		likesView.frame = CGRectMake(0, 20, likesViewWidth, label.bounds.size.height + 20)
		likesView.frame.origin.x = bounds.size.width - likesView.frame.size.width - 20
		likesView.layer.cornerRadius = 10
		likesView.layer.masksToBounds = true
		contentView.addSubview(likesView)
		likesView.addSubview(label)
		label.center = CGPointMake(likesView.bounds.size.width / 2, likesView.bounds.size.height / 2)
	}
	
	override func awakeFromNib() {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap"))
		tapGestureRecognizer.numberOfTapsRequired = 2;
		contentView.addGestureRecognizer(tapGestureRecognizer)
	}
	
	func handleTap() {
		let window = UIApplication.sharedApplication().keyWindow
		let coverView = UIView(frame: window!.frame)
		coverView.backgroundColor = UIColor.blackColor()
		window?.addSubview(coverView)
		let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("handlePinch"))
		coverView.addGestureRecognizer(pinchGestureRecognizer)
		
		let imageView = UIImageView(frame: CGRectMake(0, 0, coverView.bounds.size.width, coverView.bounds.size.width))
		imageView.center = coverView.center
		let urlString = photoInfo["images"]["standard_resolution"]["url"].string
		let url = NSURL(string: urlString!)
		let data = NSData(contentsOfURL: url!)
		imageView.image = UIImage(data: data!)
		coverView.addSubview(imageView)
	}
	
	func handlePinch() {
		let window = UIApplication.sharedApplication().keyWindow

		UIView.animateWithDuration(0.5, animations: {
			let view = window?.subviews.last! as! UIView
			view.alpha = 0
		})
	}
}

