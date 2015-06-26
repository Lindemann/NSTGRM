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

	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var myImageView: UIImageView!
	var photoInfo: SwiftyJSON.JSON = [] { didSet { setUpPhoto() } }
	
	func setUpPhoto() {
		label.text = photoInfo["caption"]["text"].string
		if let urlString = photoInfo["images"]["standard_resolution"]["url"].string {
			let url = NSURL(string: urlString)
			myImageView.hnk_setImageFromURL(url!)
		}
	}
	
	override func prepareForReuse() {
		myImageView.image = nil
	}

}
