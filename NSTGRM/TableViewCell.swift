//
//  TableViewCell.swift
//  NSTGRM
//
//  Created by Lindemann on 24/06/15.
//  Copyright (c) 2015 Lindemann. All rights reserved.
//

import UIKit
import Haneke

class TableViewCell: UITableViewCell {

	var likesView: LikesView
	
	required init(coder aDecoder: NSCoder) {
		likesView = LikesView(effect: UIBlurEffect(style: .ExtraLight)) as LikesView
		super.init(coder: aDecoder)
		initHelper()
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		likesView = LikesView(effect: UIBlurEffect(style: .ExtraLight)) as LikesView
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		initHelper()
	}
	
	func initHelper() {
		imageView?.clipsToBounds = true
		imageView?.contentMode =  UIViewContentMode.ScaleAspectFill
	}
	
	override func layoutSubviews() {
		let marginToLeftCornerOfCell: CGFloat = 20
		likesView.frame = CGRectMake(0, marginToLeftCornerOfCell, likesView.bounds.size.width, likesView.bounds.size.height)
		likesView.frame.origin.x = contentView.bounds.size.width - likesView.frame.size.width - marginToLeftCornerOfCell
		
		contentView.addSubview(imageView!)
		contentView.addSubview(likesView)
		
	}
	
	override func prepareForReuse() {
		imageView?.hnk_cancelSetImage()
		imageView?.image = nil
	}
	
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

