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

	let photoImageView = UIImageView()
	var likesView: LikesView
	
	override func layoutSubviews() {
		let marginToLeftCornerOfCell: CGFloat = 20
		likesView.frame = CGRectMake(0, marginToLeftCornerOfCell, likesView.bounds.size.width, likesView.bounds.size.height)
		likesView.frame.origin.x = contentView.bounds.size.width - likesView.frame.size.width - marginToLeftCornerOfCell
		
		contentView.addSubview(photoImageView)
		contentView.addSubview(likesView)
		
		
		photoImageView.clipsToBounds = true
		photoImageView.contentMode =  UIViewContentMode.ScaleAspectFill
	}
	
	override func prepareForReuse() {
		photoImageView.hnk_cancelSetImage()
		photoImageView.image = nil
	}
	
	required init(coder aDecoder: NSCoder) {
		likesView = LikesView(effect: UIBlurEffect(style: .ExtraLight)) as LikesView
		super.init(coder: aDecoder)
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		likesView = LikesView(effect: UIBlurEffect(style: .ExtraLight)) as LikesView
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
//	var photoInfo: SwiftyJSON.JSON = [] {
//		didSet {
//			setupPhoto()
//			setupLikes()
//		}
//	}
//	
//	func setupPhoto() {
//		// label.text = photoInfo["caption"]["text"].string
//		if let urlString = photoInfo["images"]["standard_resolution"]["url"].string {
//			
//			photoImageView.frame = bounds
//			photoImageView.contentMode = UIViewContentMode.ScaleAspectFit
//			contentView.addSubview(photoImageView)
//			
//			let url = NSURL(string: urlString)
//			let format = Format<UIImage>(name: "crop", diskCapacity: UInt64.max, transform: { (image) -> (UIImage) in
//				return self.cropImage(image, toRect: CGRectMake(
//					0,
//					image.size.height/4,
//					image.size.width,
//					image.size.height/2)
//				)
//			})
//			photoImageView.hnk_setImageFromURL(url!, format: format)
//
//			
//			
//		}
//	}
//
//	override func prepareForReuse() {
//		photoImageView.image = nil
//	}
//
//	func cropImage(image: UIImage, toRect rect: CGRect) -> UIImage {
//		var imageRef: CGImageRef = CGImageCreateWithImageInRect(image.CGImage, rect)
//		var croppedImage: UIImage = UIImage(CGImage:imageRef)!
//		return croppedImage
//	}
//	
//	func setupLikes() {
//		let likes = photoInfo["likes"]["count"]
//		let label = UILabel(frame: CGRectMake(0, 0, 0, 0))
//		label.text = "♥︎ \(likes)"
//		label.sizeToFit()
//		label.textColor = UIColor.darkGrayColor()
//		let likesView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) as UIVisualEffectView
//		likesView.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.4)
//		let likesViewWidth = (label.bounds.size.width + 20 >= 70) ? label.bounds.size.width + 20 : 70
//		likesView.frame = CGRectMake(0, 20, likesViewWidth, label.bounds.size.height + 20)
//		likesView.frame.origin.x = bounds.size.width - likesView.frame.size.width - 20
//		likesView.layer.cornerRadius = 10
//		likesView.layer.masksToBounds = true
//		contentView.addSubview(likesView)
//		likesView.addSubview(label)
//		label.center = CGPointMake(likesView.bounds.size.width / 2, likesView.bounds.size.height / 2)
//	}
	

}

class LikesView: UIVisualEffectView {
	
	private let label = UILabel()
	var likes = 0 {
		didSet {
			label.text = "♥︎ \(likes)"
			setup()
		}
	}
	
	func setup() {
		label.sizeToFit()
		label.textColor = UIColor.darkGrayColor()
		
		backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.2)
		layer.cornerRadius = 10
		layer.masksToBounds = true
		
		let padding: CGFloat = 20
		let minSize: CGFloat = 70
		let labelSize = label.bounds.size.width + padding
		let likesViewWidth = (labelSize + padding >= minSize) ? labelSize + padding : minSize
		frame = CGRectMake(0, 20, likesViewWidth, label.bounds.size.height + padding)
		
		addSubview(label)
		label.center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2)
	}
}

